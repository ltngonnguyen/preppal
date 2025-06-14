import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Date formatting.
import 'dart:async'; // For StreamSubscription
import 'dart:math' as math; // For math.max

import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added for persistence

import '../../models/stockpile_item.dart';
import '../../services/stockpile_repository.dart';
import 'add_edit_stockpile_item_dialog.dart';
import 'widgets/resource_progress_bar.dart'; // New progress bar widget

class StockpileTab extends StatefulWidget {
  const StockpileTab({super.key});

  @override
  State<StockpileTab> createState() => _StockpileTabState();
}

class _StockpileTabState extends State<StockpileTab> with TickerProviderStateMixin {
  final StockpileRepository _stockpileRepository = StockpileRepository.instance;
  String _currentFilter = "All";

  // Data and Milestones
  double _foodSupplyDays = 0.0;
  double _waterSupplyDays = 0.0;
  final Map<String, double> _otherAggregatedSupplies = {}; // Category name -> supply days/count
  final Map<String, bool> _nonBarResourcesStocked = {}; // Category name -> true if items exist

  // Store previous supply values to correctly detect milestone achievements
  double _previousFoodSupplyDays = 0.0;
  double _previousWaterSupplyDays = 0.0;
  final Map<String, double> _previousOtherAggregatedSupplies = {};

  // Trackers for already celebrated milestones - no longer static
  final Set<double> _celebratedFoodMilestones = {};
  final Set<double> _celebratedWaterMilestones = {};
  final Map<String, Set<double>> _celebratedOtherMilestones = {}; // category -> set of celebrated milestones

  double _foodMilestoneTarget = 3.0;
  double _waterMilestoneTarget = 3.0;
  final Map<String, double> _otherMilestoneTargets = {}; // Category name -> milestone target
 
  static const List<double> _milestones = [3, 7, 15, 30, 60, 90, 180, 365, 730, 1095];
  static const double _dailyWaterNeedPerPerson = 3.0; // Liters

  // Controllers
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<List<StockpileItem>>? _stockpileSubscription;

  bool _isLoadingSummary = true;

  // Animation Controllers for progress bars - managed by ResourceProgressBar itself now
  // Map<String, AnimationController> _progressAnimationControllers = {};

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadCelebratedMilestones().then((_) {
      // Data processing relies on celebrated milestones being loaded.
      // Initial data load might happen before this if _subscribeToStockpileUpdates is called directly.
      // Consider if _subscribeToStockpileUpdates should be called after loading.
      // For now, assuming _processStockpileData will correctly use the loaded sets.
      _subscribeToStockpileUpdates();
    });
  }

  Future<void> _loadCelebratedMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String>? foodMilestonesStr = prefs.getStringList('celebrated_food_milestones');
    if (foodMilestonesStr != null) {
      _celebratedFoodMilestones.addAll(foodMilestonesStr.map((e) => double.parse(e)));
    }

    List<String>? waterMilestonesStr = prefs.getStringList('celebrated_water_milestones');
    if (waterMilestonesStr != null) {
      _celebratedWaterMilestones.addAll(waterMilestonesStr.map((e) => double.parse(e)));
    }

    // For other categories, we need to iterate through known categories or discover keys
    // For simplicity, let's assume we might need to pre-populate _otherMilestoneTargets keys
    // or iterate prefs keys if they follow a pattern.
    // This part might need refinement based on how other categories are managed.
    // For now, if _otherAggregatedSupplies has keys, we try to load for them.
    // This means _load should ideally happen after an initial _processStockpileData or categories are known.
    // A safer approach is to store a list of categories that have "other" milestones.
    // Let's refine this: load based on keys found in prefs.
    final allKeys = prefs.getKeys();
    for (String key in allKeys) {
      if (key.startsWith('celebrated_other_milestones_')) {
        String categoryName = key.substring('celebrated_other_milestones_'.length);
        List<String>? otherMilestonesStr = prefs.getStringList(key);
        if (otherMilestonesStr != null) {
          _celebratedOtherMilestones[categoryName] = otherMilestonesStr.map((e) => double.parse(e)).toSet();
        }
      }
    }
    print('[StockpileTab] Loaded celebrated milestones: Food: $_celebratedFoodMilestones, Water: $_celebratedWaterMilestones, Other: $_celebratedOtherMilestones');
    if(mounted) setState(() {}); // Refresh UI if needed after loading, though logic handles it
  }

  Future<void> _saveCelebratedMilestones(String resourceName, double milestone) async {
    final prefs = await SharedPreferences.getInstance();
    String key;
    Set<double> milestonesSet;

    if (resourceName == "Food") {
      key = 'celebrated_food_milestones';
      milestonesSet = _celebratedFoodMilestones;
    } else if (resourceName == "Water") {
      key = 'celebrated_water_milestones';
      milestonesSet = _celebratedWaterMilestones;
    } else {
      key = 'celebrated_other_milestones_$resourceName';
      milestonesSet = _celebratedOtherMilestones[resourceName] ?? {};
    }
    
    // The set itself is already updated in _playCelebrationsSequentially.
    // We just need to save its current state.
    await prefs.setStringList(key, milestonesSet.map((e) => e.toString()).toList());
    print('[StockpileTab] Saved celebrated milestone $milestone for $resourceName to $key.');
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    _stockpileSubscription?.cancel();
    // _progressAnimationControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _subscribeToStockpileUpdates() {
    setState(() {
      _isLoadingSummary = true;
    });
    _stockpileSubscription = _stockpileRepository
        .getStockpileItemsStream(filter: "All") // Always get all for summary
        .listen((items) {
      _processStockpileData(items);
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
      }
    }, onError: (error) {
      if (mounted) {
         setState(() {
          _isLoadingSummary = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stockpile summary: $error'), backgroundColor: Colors.red),
        );
      }
    });
  }

  void _processStockpileData(List<StockpileItem> items) {
    print('[StockpileTab] _processStockpileData started. Item count: ${items.length}');

    // Store current values as previous before recalculating
    _previousFoodSupplyDays = _foodSupplyDays;
    _previousWaterSupplyDays = _waterSupplyDays;
    _previousOtherAggregatedSupplies.clear();
    _previousOtherAggregatedSupplies.addAll(_otherAggregatedSupplies);

    print('[StockpileTab] Stored previous supplies: Food=$_previousFoodSupplyDays, Water=$_previousWaterSupplyDays, Others=${_previousOtherAggregatedSupplies.entries.map((e) => '${e.key}:${e.value}').join(', ')}');

    double currentFoodDays = 0;
    double currentWaterLiters = 0;
    final Map<String, double> tempOtherSupplies = {}; // For categories with 'daysOfSupply'
    final Map<String, int> tempOtherCounts = {}; // For categories to count items
    final Set<String> tempNonBarStocked = {};

    for (var item in items) {
      final category = item.category ?? "Other";
      if (category.toLowerCase() == 'food') {
        currentFoodDays += item.totalDaysOfSupplyPerItem ?? 0;
      } else if (category.toLowerCase() == 'water') {
        currentWaterLiters += (item.unitVolumeLiters ?? 0) * item.quantity;
      } else {
        // For other categories, decide if they are quantifiable for "days of supply"
        // or just counted. This logic might need refinement based on actual categories.
        if (item.totalDaysOfSupplyPerItem != null && item.totalDaysOfSupplyPerItem! > 0) {
           tempOtherSupplies[category] = (tempOtherSupplies[category] ?? 0) + item.totalDaysOfSupplyPerItem!;
        } else {
           tempOtherCounts[category] = (tempOtherCounts[category] ?? 0) + item.quantity.toInt();
           tempNonBarStocked.add(category);
        }
      }
    }

    _foodSupplyDays = currentFoodDays;
    _waterSupplyDays = currentWaterLiters / _dailyWaterNeedPerPerson;

    _otherAggregatedSupplies.clear();
    // _otherMilestoneTargets.clear(); // Don't clear here, update them based on new supply
    _nonBarResourcesStocked.clear();

    tempOtherSupplies.forEach((category, supply) {
      _otherAggregatedSupplies[category] = supply;
      // Initialize target if not present, or keep existing to pass to _updateMilestoneTarget
      if (!_otherMilestoneTargets.containsKey(category)) {
        _otherMilestoneTargets[category] = _getInitialMilestoneTarget(supply, null);
      }
    });
    
    tempNonBarStocked.forEach((category) {
        // If a category was counted but also had daysOfSupply, prioritize daysOfSupply bar.
        if (!_otherAggregatedSupplies.containsKey(category)) {
             _nonBarResourcesStocked[category] = true;
        }
    });

    List<Map<String, dynamic>> allAchievedMilestones = [];

    // Update milestones and check for achievements
    print('[StockpileTab] Before Food milestone update: currentFoodDays=$currentFoodDays, _foodMilestoneTarget=$_foodMilestoneTarget, _previousFoodSupplyDays=$_previousFoodSupplyDays');
    final previousFoodDisplayMilestone = _foodMilestoneTarget; // This is the target the bar was aiming for
    var foodUpdateResult = _updateMilestoneTarget(currentFoodDays, _foodMilestoneTarget, "Food", previousFoodDisplayMilestone, _previousFoodSupplyDays);
    _foodMilestoneTarget = foodUpdateResult['nextMilestoneToAimFor'] as double;
    allAchievedMilestones.addAll(foodUpdateResult['achievedMilestones'] as List<Map<String, dynamic>>);

    print('[StockpileTab] Before Water milestone update: currentWaterDays=$_waterSupplyDays, _waterMilestoneTarget=$_waterMilestoneTarget, _previousWaterSupplyDays=$_previousWaterSupplyDays');
    final previousWaterDisplayMilestone = _waterMilestoneTarget;
    var waterUpdateResult = _updateMilestoneTarget(_waterSupplyDays, _waterMilestoneTarget, "Water", previousWaterDisplayMilestone, _previousWaterSupplyDays);
    _waterMilestoneTarget = waterUpdateResult['nextMilestoneToAimFor'] as double;
    allAchievedMilestones.addAll(waterUpdateResult['achievedMilestones'] as List<Map<String, dynamic>>);
    
    List<String> categoriesToRemove = [];
    // Iterate over a copy of keys for safe removal if a category becomes empty
    List<String> currentOtherCategories = _otherAggregatedSupplies.keys.toList();

    for (String category in currentOtherCategories) {
        final supply = _otherAggregatedSupplies[category]!; // Should exist
        final previousMilestoneForCategory = _otherMilestoneTargets[category] ?? _milestones.first;
        final oldSupplyForCategory = _previousOtherAggregatedSupplies[category] ?? 0.0;
        print('[StockpileTab] Before Other ($category) milestone update: newSupply=$supply, target=$previousMilestoneForCategory, oldSupplyForCategory=$oldSupplyForCategory');
        
        var otherUpdateResult = _updateMilestoneTarget(supply, previousMilestoneForCategory, category, previousMilestoneForCategory, oldSupplyForCategory);
        _otherMilestoneTargets[category] = otherUpdateResult['nextMilestoneToAimFor'] as double;
        allAchievedMilestones.addAll(otherUpdateResult['achievedMilestones'] as List<Map<String, dynamic>>);
    }
    
    // Clean up categories that no longer have items with supply days
    // This needs to be done carefully. If a category in _otherAggregatedSupplies is no longer in tempOtherSupplies, it means it has no items with daysOfSupply.
    // It might still have items if it's also in tempNonBarStocked.
    List<String> keysFromAggregated = _otherAggregatedSupplies.keys.toList();
    for (var key in keysFromAggregated) {
        if (!tempOtherSupplies.containsKey(key)) {
            // This category no longer has items that contribute to a progress bar.
            // It might still be in _nonBarResourcesStocked if it has other types of items.
            categoriesToRemove.add(key);
        }
    }

    categoriesToRemove.forEach((key) {
        print('[StockpileTab] Removing category $key from progress bar tracking (no more items with supply days).');
        _otherAggregatedSupplies.remove(key);
        _otherMilestoneTargets.remove(key);
        // Do not remove from _previousOtherAggregatedSupplies here, it's for the next cycle's comparison.
    });


    if (mounted) {
      setState(() {
        print('[StockpileTab] _processStockpileData finished. Triggering setState. Will play ${allAchievedMilestones.length} celebrations sequentially.');
      });
      if (allAchievedMilestones.isNotEmpty) {
        // Use a microtask to ensure setState completes build before dialogs
        Future.microtask(() => _playCelebrationsSequentially(allAchievedMilestones));
      }
    }
  }
  
  double _getInitialMilestoneTarget(double currentSupply, double? existingTarget) {
    if (existingTarget != null) {
        // If already tracking, find the milestone that current supply is working towards
        for (var milestone in _milestones) {
            if (currentSupply < milestone) return milestone;
        }
        return _milestones.last; // Maxed out or beyond last milestone
    }
    // For new categories, find the first milestone greater than current supply
    return _milestones.firstWhere((m) => currentSupply < m, orElse: () => _milestones.last);
  }

  // Added oldSupply to track changes more accurately for celebration triggers.
  // Returns a Map containing the 'nextMilestoneToAimFor' and a 'achievedMilestones' list.
  Map<String, dynamic> _updateMilestoneTarget(double currentSupply, double currentMilestoneTarget, String resourceName, double previousMilestoneTarget, double oldSupply) {
    print('[StockpileTab._updateMilestoneTarget for $resourceName] Start: currentSupply=$currentSupply, currentTarget=$currentMilestoneTarget, previousTarget=$previousMilestoneTarget, oldSupply=$oldSupply');
    
    List<Map<String, dynamic>> achievedThisUpdate = [];
    double nextMilestoneToAimFor = currentMilestoneTarget;
    // bool initialTargetWasHitOrExceeded = currentSupply >= currentMilestoneTarget; // Not directly used, but good for context

    // Iteratively check and celebrate milestones if current supply has jumped over them
    // This loop will handle multiple milestone achievements in one update.
    // double effectiveCurrentTarget = currentMilestoneTarget;  // Not strictly needed with new logic
    // If previousMilestoneTarget was higher (e.g. items removed), start checking from a lower milestone.
    // if (previousMilestoneTarget > currentMilestoneTarget && currentSupply < previousMilestoneTarget) {
    //     effectiveCurrentTarget = _milestones.firstWhere((m) => oldSupply < m, orElse: () => _milestones.last);
    //     print('[StockpileTab._updateMilestoneTarget for $resourceName] Supply decreased below previous target. Adjusted effectiveCurrentTarget to $effectiveCurrentTarget');
    // }


    // Find the actual milestone we should be working towards based on current supply
    // This will be the target for the progress bar.
    nextMilestoneToAimFor = _milestones.firstWhere((m) => currentSupply < m, orElse: () => _milestones.last);
    if (currentSupply >= _milestones.last) { // If supply meets or exceeds the largest milestone
        nextMilestoneToAimFor = _milestones.last;
    }
    print('[StockpileTab._updateMilestoneTarget for $resourceName] Initial nextMilestoneToAimFor calculated as: $nextMilestoneToAimFor');


    // Milestone Achievement Check
    // Iterate through milestones between the old supply's position and new supply's position
    for (final milestoneValue in _milestones) {
        bool justCrossedThisMilestone = currentSupply >= milestoneValue && oldSupply < milestoneValue;
        bool alreadyCelebrated = false;

        if (resourceName == "Food") {
            alreadyCelebrated = _celebratedFoodMilestones.contains(milestoneValue);
        } else if (resourceName == "Water") {
            alreadyCelebrated = _celebratedWaterMilestones.contains(milestoneValue);
        } else if (_celebratedOtherMilestones.containsKey(resourceName)) {
            alreadyCelebrated = _celebratedOtherMilestones[resourceName]!.contains(milestoneValue);
        }

        if (justCrossedThisMilestone && !alreadyCelebrated) {
            if (milestoneValue > 0 ) { // Don't celebrate 0 day milestones
                print('[StockpileTab._updateMilestoneTarget for $resourceName] Milestone $milestoneValue DETECTED as newly achieved (not celebrated yet)! currentSupply=$currentSupply, oldSupply=$oldSupply.');
                achievedThisUpdate.add({'resourceName': resourceName, 'milestone': milestoneValue});
            }
        } else if (justCrossedThisMilestone && alreadyCelebrated) {
            print('[StockpileTab._updateMilestoneTarget for $resourceName] Milestone $milestoneValue was crossed (currentSupply=$currentSupply, oldSupply=$oldSupply), but already celebrated.');
        }
    }
    
    // If current supply is less than the original currentMilestoneTarget (due to item removal),
    // we need to ensure nextMilestoneToAimFor is correctly set to the milestone just above the new currentSupply.
    if (currentSupply < currentMilestoneTarget) { // This check is specifically for when items are REMOVED
        nextMilestoneToAimFor = _milestones.firstWhere((m) => currentSupply < m, orElse: () => _milestones.last);
         print('[StockpileTab._updateMilestoneTarget for $resourceName] Supply $currentSupply is less than original target $currentMilestoneTarget (items removed?). Adjusted nextMilestoneToAimFor to $nextMilestoneToAimFor');
    }


    // If the supply is exactly on a milestone that it's aiming for, and it's not the last one,
    // the *next* target should be the one after that.
    // This ensures the bar shows 0% for the next tier if a milestone is exactly met.
    if (currentSupply >= nextMilestoneToAimFor && nextMilestoneToAimFor != _milestones.last) {
        int currentIndex = _milestones.indexOf(nextMilestoneToAimFor);
        if (currentIndex != -1 && currentSupply >= _milestones[currentIndex]) { // Check if current supply actually meets or exceeds this milestone
             if (currentIndex + 1 < _milestones.length) {
                nextMilestoneToAimFor = _milestones[currentIndex + 1];
                print('[StockpileTab._updateMilestoneTarget for $resourceName] Supply $currentSupply meets/exceeds current aim $nextMilestoneToAimFor (not last). Advanced nextMilestoneToAimFor to ${_milestones[currentIndex+1]}');
             }
        }
    }
    
    // Ensure that if current supply is greater than or equal to the highest milestone, the target is the highest milestone.
    // And the bar should show 100% if currentSupply >= _milestones.last
    if (currentSupply >= _milestones.last) {
        nextMilestoneToAimFor = _milestones.last; // Target is the last milestone
        print('[StockpileTab._updateMilestoneTarget for $resourceName] Supply $currentSupply meets/exceeds last milestone. Set nextMilestoneToAimFor to ${_milestones.last}');
    }


    print('[StockpileTab._updateMilestoneTarget for $resourceName] End. Returning nextMilestoneToAimFor: $nextMilestoneToAimFor, Achieved: ${achievedThisUpdate.length}');
    return {'nextMilestoneToAimFor': nextMilestoneToAimFor, 'achievedMilestones': achievedThisUpdate};
  }

  Future<void> _triggerMilestoneCelebration(String resourceName, double achievedMilestone) async {
    if (!mounted) return;
    print('[StockpileTab._triggerMilestoneCelebration] Celebrating $resourceName - ${achievedMilestone} days.');
    _confettiController.play();
    // Consider playing sound only once if multiple dialogs show, or per dialog.
    // For now, per dialog.
    _audioPlayer.play(AssetSource('sounds/milestone_achieved.wav'));

    // Using await here will pause _playCelebrationsSequentially until dialog is dismissed
    await showDialog(
      context: context,
      barrierDismissible: false, // User must interact with dialog
      builder: (context) => AlertDialog(
        title: const Text('🎉 Milestone Achieved! 🎉'),
        content: Text('Congratulations! You now have ${achievedMilestone.toInt()} days of $resourceName!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
    // Stop confetti after dialog is dismissed, or let it run its course based on its own duration.
    // _confettiController.stop(); // Optional: stop confetti here
  }

  Future<void> _playCelebrationsSequentially(List<Map<String, dynamic>> achievements) async {
    if (!mounted) return;
    print('[StockpileTab._playCelebrationsSequentially] Starting to play ${achievements.length} celebrations.');
    for (var achievement in achievements) {
      if (!mounted) break; // Stop if widget is disposed during sequence
      final resourceName = achievement['resourceName'] as String;
      final milestone = achievement['milestone'] as double;
      
      // Double check it hasn't been celebrated by a rapid successive call (though less likely now)
      bool alreadyMarkedAsCelebrated = false;
      if (resourceName == "Food") alreadyMarkedAsCelebrated = _celebratedFoodMilestones.contains(milestone);
      else if (resourceName == "Water") alreadyMarkedAsCelebrated = _celebratedWaterMilestones.contains(milestone);
      else if (_celebratedOtherMilestones.containsKey(resourceName)) alreadyMarkedAsCelebrated = _celebratedOtherMilestones[resourceName]!.contains(milestone);

      if (alreadyMarkedAsCelebrated) {
        print('[StockpileTab._playCelebrationsSequentially] Skipping $resourceName - $milestone, already marked celebrated before dialog.');
        continue;
      }

      print('[StockpileTab._playCelebrationsSequentially] Now celebrating $resourceName - $milestone days.');
      await _triggerMilestoneCelebration(resourceName, milestone);
      
      // Mark as celebrated AFTER the dialog is dismissed
      if (mounted) { // Check mounted again as await might have taken time
        bool newlyMarked = false;
        if (resourceName == "Food") {
          newlyMarked = _celebratedFoodMilestones.add(milestone);
          if(newlyMarked) print('[StockpileTab._playCelebrationsSequentially] Marked Food milestone $milestone as celebrated.');
        } else if (resourceName == "Water") {
          newlyMarked = _celebratedWaterMilestones.add(milestone);
          if(newlyMarked) print('[StockpileTab._playCelebrationsSequentially] Marked Water milestone $milestone as celebrated.');
        } else {
          newlyMarked = _celebratedOtherMilestones.putIfAbsent(resourceName, () => {}).add(milestone);
          if(newlyMarked) print('[StockpileTab._playCelebrationsSequentially] Marked Other ($resourceName) milestone $milestone as celebrated.');
        }
        if (newlyMarked) {
          await _saveCelebratedMilestones(resourceName, milestone);
        }
      }
      // Optional: Add a small delay between celebrations if desired
      // await Future.delayed(const Duration(milliseconds: 500));
    }
    print('[StockpileTab._playCelebrationsSequentially] Finished playing all celebrations.');
  }

  void _showAddItemDialog({StockpileItem? item}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog not dismissible by tapping outside.
      builder: (BuildContext context) {
        return AddEditStockpileItemDialog(item: item);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Emergency Stockpile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddItemDialog(),
            tooltip: 'Add Item',
          ),
        ],
      ),
      body: Stack( // Use Stack for Confetti
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              _buildFilterChips(),
              _buildSummarySection(), // New summary section
              const Divider(),
              _buildStockpileList(), // Existing list view, ensure it's Expanded
            ],
          ),
          ConfettiWidget( // Confetti overlay
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
            ],
            gravity: 0.2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FilterChip(label: const Text('All'), selected: _currentFilter == "All", onSelected: (sel) => setState(() => _currentFilter = "All")),
          FilterChip(label: const Text('Food'), selected: _currentFilter == "Food", onSelected: (sel) => setState(() => _currentFilter = "Food")),
          FilterChip(label: const Text('Water'), selected: _currentFilter == "Water", onSelected: (sel) => setState(() => _currentFilter = "Water")),
          FilterChip(label: const Text('Expiring Soon'), selected: _currentFilter == "Expiring", onSelected: (sel) => setState(() => _currentFilter = "Expiring")),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    if (_isLoadingSummary) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    List<Widget> summaryWidgets = [];

    // Food Progress Bar
    summaryWidgets.add(
      ResourceProgressBar(
        key: ValueKey('food_${_foodSupplyDays}_$_foodMilestoneTarget'), // Ensure widget rebuilds
        resourceName: 'Food Supply',
        currentSupply: _foodSupplyDays,
        milestoneTarget: _foodMilestoneTarget,
        progressBarColor: Colors.green,
        unit: 'days',
      ),
    );

    // Water Progress Bar
    summaryWidgets.add(
      ResourceProgressBar(
        key: ValueKey('water_${_waterSupplyDays}_$_waterMilestoneTarget'),
        resourceName: 'Water Supply',
        currentSupply: _waterSupplyDays,
        milestoneTarget: _waterMilestoneTarget,
        progressBarColor: Colors.blue,
        unit: 'days',
      ),
    );

    // Other Trackable Resources
    _otherAggregatedSupplies.forEach((category, supply) {
      final milestone = _otherMilestoneTargets[category] ?? _milestones.last;
      // Determine color based on category - could be more sophisticated
      Color categoryColor = Colors.primaries[category.hashCode % Colors.primaries.length];
      summaryWidgets.add(
        ResourceProgressBar(
          key: ValueKey('${category}_${supply}_$milestone'),
          resourceName: '$category Supply',
          currentSupply: supply,
          milestoneTarget: milestone,
          progressBarColor: categoryColor,
          unit: 'days', // Assuming 'days' for now, might need adjustment
        ),
      );
    });
    
    // Non-Bar Resources
    _nonBarResourcesStocked.forEach((category, stocked) {
        if (stocked && !_otherAggregatedSupplies.containsKey(category)) { // Ensure it's not already a progress bar
             summaryWidgets.add(
                Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: ListTile(
                        leading: Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor),
                        title: Text('$category: Items Stocked'),
                    ),
                )
             );
        }
    });


    if (summaryWidgets.isEmpty && !_isLoadingSummary) {
        return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                "No summary data available. Add items to your stockpile.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
            ),
        );
    }


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stockpile Summary:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (summaryWidgets.isNotEmpty)
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // if inside another scrollview
              children: summaryWidgets,
            )
          else if (!_isLoadingSummary) // Only show if not loading and no widgets
             Center(child: Text("Add items to see your stockpile summary.", style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildStockpileList() {
    return Expanded(
      child: StreamBuilder<List<StockpileItem>>(
        stream: _stockpileRepository.getStockpileItemsStream(filter: _currentFilter),
        builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView( // Added to prevent overflow for empty message
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sentiment_dissatisfied_outlined, size: 80, color: Colors.grey),
                            const SizedBox(height: 20),
                            Text(
                              'Your stockpile is empty.',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tap the "+" icon in the top bar to add your first item.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final allItems = snapshot.data!;
                // TODO: Implement filtering logic based on _currentFilter.
                final items = allItems; // Using all items until filtering is implemented.

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    bool isExpiringSoon = item.expiryDate != null && item.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
                    bool isExpired = item.expiryDate != null && item.expiryDate!.isBefore(DateTime.now());

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} (${item.quantity} ${item.unit ?? ''})'.trim(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
                                      onPressed: () => _showAddItemDialog(item: item),
                                      tooltip: 'Edit Item',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirm Delete'),
                                              content: Text('Are you sure you want to delete "${item.name}"?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                ),
                                                TextButton(
                                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (confirm == true && item.id != null) {
                                          try {
                                            // await _firestoreService.deleteStockpileItem(item.id!); // Replaced
                                            await _stockpileRepository.delete(item.id!); // Updated
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('"${item.name}" deleted.')),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error deleting item: $e'), backgroundColor: Theme.of(context).colorScheme.error),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      tooltip: 'Delete Item',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (item.expiryDate != null)
                              Text(
                                'Expires: ${DateFormat.yMMMd().format(item.expiryDate!)}'
                                '${isExpired ? " - EXPIRED!" : isExpiringSoon ? " - EXPIRING SOON!" : ""}',
                                style: TextStyle(
                                  color: isExpired ? Colors.red : (isExpiringSoon ? Colors.orangeAccent : null),
                                  fontWeight: isExpired || isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('Notes: ${item.notes}', style: Theme.of(context).textTheme.bodySmall),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ); // Closes Expanded widget and the return statement for _buildStockpileList
  } // Closes the _buildStockpileList method

  // FloatingActionButton removed; "Add Item" is in AppBar as per wireframe.

} // Closes the _StockpileTabState class