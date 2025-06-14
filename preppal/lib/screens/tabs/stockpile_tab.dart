import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date format
import 'dart:async'; // async stuff
import 'dart:math' as math; // for math

import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart'; // save stuff

import '../../models/stockpile_item.dart';
import '../../services/stockpile_repository.dart';
import 'add_edit_stockpile_item_dialog.dart';
import 'widgets/resource_progress_bar.dart'; // progress bar widget

class StockpileTab extends StatefulWidget {
  const StockpileTab({super.key});

  @override
  State<StockpileTab> createState() => _StockpileTabState();
}

class _StockpileTabState extends State<StockpileTab> with TickerProviderStateMixin {
  final StockpileRepository _stockpileRepository = StockpileRepository.instance;
  String _currentFilter = "All";

  // supply data
  double _foodSupplyDays = 0.0;
  double _waterSupplyDays = 0.0;
  final Map<String, double> _otherAggregatedSupplies = {}; // Category -> supply days/count
  final Map<String, bool> _nonBarResourcesStocked = {}; // Category -> true if items exist

  // old supply values
  double _previousFoodSupplyDays = 0.0;
  double _previousWaterSupplyDays = 0.0;
  final Map<String, double> _previousOtherAggregatedSupplies = {};

  // celebrated ones
  final Set<double> _celebratedFoodMilestones = {};
  final Set<double> _celebratedWaterMilestones = {};
  final Map<String, Set<double>> _celebratedOtherMilestones = {}; // other celebrated

  double _foodMilestoneTarget = 3.0;
  double _waterMilestoneTarget = 3.0;
  final Map<String, double> _otherMilestoneTargets = {}; // other targets
 
  static const List<double> _milestones = [3, 7, 15, 30, 60, 90, 180, 365, 730, 1095];
  static const double _dailyWaterNeedPerPerson = 3.0; // L

  // controls
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<List<StockpileItem>>? _stockpileSubscription;

  bool _isLoadingSummary = true;

  // animation controllers for progress
  // Map<String, AnimationController> _progressAnimationControllers = {};

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _loadCelebratedMilestones().then((_) {
      // load milestones first
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

    // load other celebrated milestones
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
    if(mounted) setState(() {}); // update ui
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
    
    // save current celebrated
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
        .getStockpileItemsStream(filter: "All") // get all items for summary
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

  Future<void> _processStockpileData(List<StockpileItem> items) async { // now async
    print('[StockpileTab] _processStockpileData started. Item count: ${items.length}');

    // save old values
    _previousFoodSupplyDays = _foodSupplyDays;
    _previousWaterSupplyDays = _waterSupplyDays;
    _previousOtherAggregatedSupplies.clear();
    _previousOtherAggregatedSupplies.addAll(_otherAggregatedSupplies);

    print('[StockpileTab] Stored previous supplies: Food=$_previousFoodSupplyDays, Water=$_previousWaterSupplyDays, Others=${_previousOtherAggregatedSupplies.entries.map((e) => '${e.key}:${e.value}').join(', ')}');

    double currentFoodDays = 0;
    double currentWaterLiters = 0;
    final Map<String, double> tempOtherSupplies = {}; // supplies with days
    final Map<String, int> tempOtherCounts = {}; // supplies to count
    final Set<String> tempNonBarStocked = {};

    for (var item in items) {
      final category = item.category ?? "Other";
      if (category.toLowerCase() == 'food') {
        currentFoodDays += item.totalDaysOfSupplyPerItem ?? 0;
      } else if (category.toLowerCase() == 'water') {
        currentWaterLiters += (item.unitVolumeLiters ?? 0) * item.quantity;
      } else {
        // handle other categories
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
    // _otherMilestoneTargets.clear(); // keep existing targets
    _nonBarResourcesStocked.clear();

    tempOtherSupplies.forEach((category, supply) {
      _otherAggregatedSupplies[category] = supply;
      // set initial target if needed
      if (!_otherMilestoneTargets.containsKey(category)) {
        _otherMilestoneTargets[category] = _getInitialMilestoneTarget(supply, null);
      }
    });
    
    tempNonBarStocked.forEach((category) {
        // only if not already a bar
        if (!_otherAggregatedSupplies.containsKey(category)) {
             _nonBarResourcesStocked[category] = true;
        }
    });

    List<Map<String, dynamic>> allAchievedMilestones = [];

    // check milestones
    print('[StockpileTab] Before Food milestone update: currentFoodDays=$currentFoodDays, _foodMilestoneTarget=$_foodMilestoneTarget, _previousFoodSupplyDays=$_previousFoodSupplyDays');
    final previousFoodDisplayMilestone = _foodMilestoneTarget; // old target for bar
    var foodUpdateResult = await _updateMilestoneTarget(currentFoodDays, _foodMilestoneTarget, "Food", previousFoodDisplayMilestone, _previousFoodSupplyDays); // needs await
    _foodMilestoneTarget = foodUpdateResult['nextMilestoneToAimFor'] as double;
    allAchievedMilestones.addAll(foodUpdateResult['achievedMilestones'] as List<Map<String, dynamic>>);

    print('[StockpileTab] Before Water milestone update: currentWaterDays=$_waterSupplyDays, _waterMilestoneTarget=$_waterMilestoneTarget, _previousWaterSupplyDays=$_previousWaterSupplyDays');
    final previousWaterDisplayMilestone = _waterMilestoneTarget;
    var waterUpdateResult = await _updateMilestoneTarget(_waterSupplyDays, _waterMilestoneTarget, "Water", previousWaterDisplayMilestone, _previousWaterSupplyDays); // needs await
    _waterMilestoneTarget = waterUpdateResult['nextMilestoneToAimFor'] as double;
    allAchievedMilestones.addAll(waterUpdateResult['achievedMilestones'] as List<Map<String, dynamic>>);
    
    List<String> categoriesToRemove = [];
    // use copy of keys for safe removal
    List<String> currentOtherCategories = _otherAggregatedSupplies.keys.toList();

    for (String category in currentOtherCategories) {
        final supply = _otherAggregatedSupplies[category]!; // must exist
        final previousMilestoneForCategory = _otherMilestoneTargets[category] ?? _milestones.first;
        final oldSupplyForCategory = _previousOtherAggregatedSupplies[category] ?? 0.0;
        print('[StockpileTab] Before Other ($category) milestone update: newSupply=$supply, target=$previousMilestoneForCategory, oldSupplyForCategory=$oldSupplyForCategory');
        
        var otherUpdateResult = await _updateMilestoneTarget(supply, previousMilestoneForCategory, category, previousMilestoneForCategory, oldSupplyForCategory); // needs await
        _otherMilestoneTargets[category] = otherUpdateResult['nextMilestoneToAimFor'] as double;
        allAchievedMilestones.addAll(otherUpdateResult['achievedMilestones'] as List<Map<String, dynamic>>);
    }
    
    // remove categories carefully
    List<String> keysFromAggregated = _otherAggregatedSupplies.keys.toList();
    for (var key in keysFromAggregated) {
        if (!tempOtherSupplies.containsKey(key)) {
            // no longer has progress bar items
            categoriesToRemove.add(key);
        }
    }

    categoriesToRemove.forEach((key) {
        print('[StockpileTab] Removing category $key from progress bar tracking (no more items with supply days).');
        _otherAggregatedSupplies.remove(key);
        _otherMilestoneTargets.remove(key);
        // keep for next comparison
    });


    if (mounted) {
      setState(() {
        print('[StockpileTab] _processStockpileData finished. Triggering setState. Will play ${allAchievedMilestones.length} celebrations sequentially.');
        // (debug log removed)
        // print('[StockpileTab DEBUG] Achieved Milestones before play: $allAchievedMilestones');
      });
      if (allAchievedMilestones.isNotEmpty) {
        // microtask for dialogs after build
        Future.microtask(() => _playCelebrationsSequentially(allAchievedMilestones));
      }
    }
  }
  
  double _getInitialMilestoneTarget(double currentSupply, double? existingTarget) {
    if (existingTarget != null) {
        // find next milestone if tracking
        for (var milestone in _milestones) {
            if (currentSupply < milestone) return milestone;
        }
        return _milestones.last; // maxed out
    }
    // new category, find first milestone
    return _milestones.firstWhere((m) => currentSupply < m, orElse: () => _milestones.last);
  }

  // oldSupply for better celebration check
  // returns next target and achieved list
  // now async, returns Future
  Future<Map<String, dynamic>> _updateMilestoneTarget(double currentSupply, double currentMilestoneTarget, String resourceName, double previousMilestoneTarget, double oldSupply) async {
    print('[StockpileTab._updateMilestoneTarget for $resourceName] Start: currentSupply=$currentSupply, currentTarget=$currentMilestoneTarget, previousTarget=$previousMilestoneTarget, oldSupply=$oldSupply');
    
    List<Map<String, dynamic>> achievedThisUpdate = [];
    double nextMilestoneToAimFor = currentMilestoneTarget;
    // (unused variable)

    // check multiple achievements
    // (not needed)
    // if items removed, check lower milestones


    // target for progress bar
    nextMilestoneToAimFor = _milestones.firstWhere((m) => currentSupply < m, orElse: () => _milestones.last);
    if (currentSupply >= _milestones.last) { // if supply is >= largest milestone
        nextMilestoneToAimFor = _milestones.last;
    }
    print('[StockpileTab._updateMilestoneTarget for $resourceName] Initial nextMilestoneToAimFor calculated as: $nextMilestoneToAimFor');


    // check for achieved milestones
    // check milestones between old and new supply
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

        // (debug log removed)
        // print('[StockpileTab DEBUG _updateMilestoneTarget for $resourceName] Checking milestone: $milestoneValue. currentSupply: $currentSupply, oldSupply: $oldSupply, justCrossed: $justCrossedThisMilestone, alreadyCelebrated: $alreadyCelebrated');

        if (justCrossedThisMilestone && !alreadyCelebrated) {
            if (milestoneValue > 0 ) { // no 0 day celebrations
                print('[StockpileTab._updateMilestoneTarget for $resourceName] Milestone $milestoneValue DETECTED as newly achieved (not celebrated yet)! currentSupply=$currentSupply, oldSupply=$oldSupply.');
                achievedThisUpdate.add({'resourceName': resourceName, 'milestone': milestoneValue});
            }
        } else if (currentSupply < milestoneValue && alreadyCelebrated) {
            // un-celebrate if supply drops
            bool removedSuccessfully = false;
            if (resourceName == "Food") {
                removedSuccessfully = _celebratedFoodMilestones.remove(milestoneValue);
            } else if (resourceName == "Water") {
                removedSuccessfully = _celebratedWaterMilestones.remove(milestoneValue);
            } else if (_celebratedOtherMilestones.containsKey(resourceName)) {
                removedSuccessfully = _celebratedOtherMilestones[resourceName]!.remove(milestoneValue);
                if (removedSuccessfully && _celebratedOtherMilestones[resourceName]!.isEmpty) {
                    _celebratedOtherMilestones.remove(resourceName); // cleanup map
                    print('[StockpileTab._updateMilestoneTarget for $resourceName] Also removed empty set from _celebratedOtherMilestones.');
                }
            }

            if (removedSuccessfully) {
                print('[StockpileTab._updateMilestoneTarget for $resourceName] Milestone $milestoneValue UN-CELEBRATED (supply dropped below $milestoneValue). Persisting change.');
                await _saveCelebratedMilestones(resourceName, milestoneValue); // save removal
            }
        } else if (justCrossedThisMilestone && alreadyCelebrated) {
            print('[StockpileTab._updateMilestoneTarget for $resourceName] Milestone $milestoneValue was crossed (currentSupply=$currentSupply, oldSupply=$oldSupply), but already celebrated.');
        } else {
            // (debug log removed)
            if (!justCrossedThisMilestone && !alreadyCelebrated) { // log missed new celebration
                 print('[StockpileTab _updateMilestoneTarget for $resourceName] Milestone $milestoneValue NOT added for celebration. justCrossed: $justCrossedThisMilestone (current: $currentSupply, old: $oldSupply), alreadyCelebrated: $alreadyCelebrated.');
            }
        }
    }
    
    // if items removed, adjust target
    if (currentSupply < currentMilestoneTarget) { // for item removal
        nextMilestoneToAimFor = _milestones.firstWhere((m) => currentSupply < m, orElse: () => _milestones.last);
         print('[StockpileTab._updateMilestoneTarget for $resourceName] Supply $currentSupply is less than original target $currentMilestoneTarget (items removed?). Adjusted nextMilestoneToAimFor to $nextMilestoneToAimFor');
    }


    // if on milestone, aim for next one
    if (currentSupply >= nextMilestoneToAimFor && nextMilestoneToAimFor != _milestones.last) {
        int currentIndex = _milestones.indexOf(nextMilestoneToAimFor);
        if (currentIndex != -1 && currentSupply >= _milestones[currentIndex]) { // if supply >= this milestone
             if (currentIndex + 1 < _milestones.length) {
                nextMilestoneToAimFor = _milestones[currentIndex + 1];
                print('[StockpileTab._updateMilestoneTarget for $resourceName] Supply $currentSupply meets/exceeds current aim $nextMilestoneToAimFor (not last). Advanced nextMilestoneToAimFor to ${_milestones[currentIndex+1]}');
             }
        }
    }
    
    // if supply >= highest, target is highest
    if (currentSupply >= _milestones.last) {
        nextMilestoneToAimFor = _milestones.last; // target last milestone
        print('[StockpileTab._updateMilestoneTarget for $resourceName] Supply $currentSupply meets/exceeds last milestone. Set nextMilestoneToAimFor to ${_milestones.last}');
    }


    print('[StockpileTab._updateMilestoneTarget for $resourceName] End. Returning nextMilestoneToAimFor: $nextMilestoneToAimFor, Achieved: ${achievedThisUpdate.length}');
    return {'nextMilestoneToAimFor': nextMilestoneToAimFor, 'achievedMilestones': achievedThisUpdate};
  }

  Future<void> _triggerMilestoneCelebration(String resourceName, double achievedMilestone) async {
    if (!mounted) return;
    print('[StockpileTab._triggerMilestoneCelebration] Celebrating $resourceName - ${achievedMilestone} days.');
    _confettiController.play();
    // sound per dialog for now
    _audioPlayer.play(AssetSource('sounds/milestone_achieved.wav'));

    // await pauses sequence
    await showDialog(
      context: context,
      barrierDismissible: false, // user must click
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
    // optional: stop confetti
    // _confettiController.stop(); // stop confetti
  }

  Future<void> _playCelebrationsSequentially(List<Map<String, dynamic>> achievements) async {
    if (!mounted) return;
    print('[StockpileTab._playCelebrationsSequentially] Starting to play ${achievements.length} celebrations.');
    for (var achievement in achievements) {
      if (!mounted) break; // stop if disposed
      final resourceName = achievement['resourceName'] as String;
      final milestone = achievement['milestone'] as double;
      
      // check again if celebrated
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
      
      // mark after dialog
      if (mounted) { // check mounted after await
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
      // optional delay
      // await Future.delayed(const Duration(milliseconds: 500));
    }
    print('[StockpileTab._playCelebrationsSequentially] Finished playing all celebrations.');
  }

  void _showAddItemDialog({StockpileItem? item}) {
    showDialog(
      context: context,
      barrierDismissible: false, // not dismissible by tap outside
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
      body: Stack( // for confetti
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              _buildFilterChips(),
              _buildSummarySection(), // summary section
              const Divider(),
              _buildStockpileList(), // list view, needs Expanded
            ],
          ),
          ConfettiWidget( // confetti
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
        key: ValueKey('food_${_foodSupplyDays}_$_foodMilestoneTarget'), // to rebuild widget
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
      // color by category
      Color categoryColor = Colors.primaries[category.hashCode % Colors.primaries.length];
      summaryWidgets.add(
        ResourceProgressBar(
          key: ValueKey('${category}_${supply}_$milestone'),
          resourceName: '$category Supply',
          currentSupply: supply,
          milestoneTarget: milestone,
          progressBarColor: categoryColor,
          unit: 'days', // unit is days, maybe change later
        ),
      );
    });
    
    // Non-Bar Resources
    _nonBarResourcesStocked.forEach((category, stocked) {
        if (stocked && !_otherAggregatedSupplies.containsKey(category)) { // if not already a bar
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


    if (summaryWidgets.isEmpty && !_isLoadingSummary) { // show if not loading and no widgets
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
              physics: const NeverScrollableScrollPhysics(), // if inside scrollview
              children: summaryWidgets,
            )
          else if (!_isLoadingSummary) // show if not loading and no widgets
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
                      child: SingleChildScrollView( // prevent overflow
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
                // TODO: filter logic
                final items = allItems; // use all for now

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
                                      icon: const Icon(Icons.delete_outlined, color: Colors.redAccent),
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
                                            // await _firestoreService.deleteStockpileItem(item.id!); // old way
                                            await _stockpileRepository.delete(item.id!); // new way
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
          ); // end Expanded for _buildStockpileList
  } // end _buildStockpileList

  // FAB removed, add item in appbar

} // end _StockpileTabState