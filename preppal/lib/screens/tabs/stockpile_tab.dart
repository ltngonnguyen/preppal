import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Date formatting.
import '../../models/stockpile_item.dart';
import '../../services/firestore_service.dart';
import 'add_edit_stockpile_item_dialog.dart'; // Dialog for adding/editing items.

class StockpileTab extends StatefulWidget {
  const StockpileTab({super.key});

  @override
  State<StockpileTab> createState() => _StockpileTabState();
}

class _StockpileTabState extends State<StockpileTab> {
  final FirestoreService _firestoreService = FirestoreService();

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
    // TODO: Implement full filter/sort state management and logic.
    String _currentFilter = "All"; // Example filter state, move to state variable.

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Emergency Stockpile'),
        // Back button is handled by Navigator if this screen is pushed.
        // If used as a tab without a nested Navigator, explicit back button might be needed
        // if there's a concept of navigating "back" within the tab's content.
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddItemDialog(),
            tooltip: 'Add Item',
          ),
        ],
      ),
      body: Column(
        children: [
          // Placeholder for filter/sort options.
          Padding(
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
          ),
          // Placeholder for stockpile summary.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stockpile Summary:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // TODO: Populate summary with dynamic data (e.g., total water, food days).
                const Text('- Water: [X] Liters (Goal: [Y] Liters)'),
                const Text('- Food (Non-Perishable): [Z] Days (Goal: [W] Days)'),
                const SizedBox(height: 4),
                // TODO: Implement dynamic progress bar for kit completeness.
                const LinearProgressIndicator(value: 0.6, minHeight: 10), // Example.
                const SizedBox(height: 10),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<StockpileItem>>(
              stream: _firestoreService.getStockpileItems(), // TODO: Apply filtering to this stream or filter results locally.
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
                                            await _firestoreService.deleteStockpileItem(item.id!);
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
          ),
        ],
      ),
      // FloatingActionButton removed; "Add Item" is in AppBar as per wireframe.
    );
  }
}