import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/stockpile_item.dart';
import '../../services/firestore_service.dart';

class AddEditStockpileItemDialog extends StatefulWidget {
  final StockpileItem? item; // Provided item for editing, null for adding.

  const AddEditStockpileItemDialog({super.key, this.item});

  @override
  State<AddEditStockpileItemDialog> createState() => _AddEditStockpileItemDialogState();
}

class _AddEditStockpileItemDialogState extends State<AddEditStockpileItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController; // Controller for custom unit text.
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  DateTime? _expiryDate;
  String? _selectedReminder; // Stores selected reminder option.

  bool _isLoading = false; // Tracks loading state for save operation.

  // Default list of item categories.
  final List<String> _categories = [
    'Food', 'Water', 'First Aid', 'Tools', 'Documents', 'Medication', 'Sanitation', 'Other'
  ];
  String? _selectedCategory; // Currently selected category.

  // Default list of item units.
  final List<String> _units = ['pcs', 'kg', 'g', 'L', 'mL', 'can', 'bottle', 'box', 'roll', 'tube', 'kit', 'set', 'other'];
  String? _selectedUnit; // Currently selected unit.

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '1');
    _unitController = TextEditingController(text: widget.item?.unit ?? '');
    _categoryController = TextEditingController(text: widget.item?.category ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _expiryDate = widget.item?.expiryDate;
    _selectedCategory = widget.item?.category;
    _selectedUnit = widget.item?.unit;

    // If editing an item with a unit not in the default list, add it.
    if (_selectedUnit != null && !_units.contains(_selectedUnit!)) {
      _units.add(_selectedUnit!);
    }
    // No default unit selection; user explicitly chooses or types.

    // If editing an item with a category not in the default list, add it.
    if (_selectedCategory != null && !_categories.contains(_selectedCategory!)) {
      _categories.add(_selectedCategory!);
    }
    // Default to the first category if adding a new item and no category is pre-selected.
    if (_selectedCategory == null && _categories.isNotEmpty) {
        _selectedCategory = _categories[0];
    }
    // Initialize reminder preference from the item being edited.
    _selectedReminder = widget.item?.reminderPreference;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _expiryDate) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      final String? userId = _auth.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.'), backgroundColor: Colors.red),
        );
        setState(() { _isLoading = false; });
        return;
      }

      final newItem = StockpileItem(
        id: widget.item?.id,
        name: _nameController.text.trim(),
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
        unit: _selectedUnit == 'other' ? _unitController.text.trim() : _selectedUnit,
        category: _selectedCategory ?? _categoryController.text.trim(),
        expiryDate: _expiryDate,
        reminderPreference: _selectedReminder,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        addedDate: widget.item?.addedDate ?? DateTime.now(), // Preserve original add date if editing.
        userId: userId,
      );

      try {
        if (widget.item == null) {
          await _firestoreService.addStockpileItem(newItem);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item added successfully!')),
          );
        } else {
          await _firestoreService.updateStockpileItem(newItem);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item updated successfully!')),
          );
        }
        Navigator.of(context).pop(); // Close dialog on success.
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Add New Stockpile Item' : 'Edit Stockpile Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid positive quantity';
                  }
                  return null;
                },
              ),
              // Unit input: Dropdown for predefined units, text field for 'other'.
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: _units.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUnit = newValue;
                          // If 'other' is not selected, clear the custom unit text field.
                          if (newValue != 'other') {
                            _unitController.clear();
                          }
                        });
                      },
                      // Unit validation can be optional.
                    ),
                  ),
                  // Show text field only if 'other' unit is selected.
                  if (_selectedUnit == 'other') ...[
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(labelText: 'Specify Unit'),
                        validator: (value) {
                          if (_selectedUnit == 'other' && (value == null || value.isEmpty)) {
                            return 'Specify unit';
                          }
                          return null;
                        },
                      ),
                    ),
                  ]
                ],
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    // If 'Other' is not selected, clear the custom category text field.
                    if (newValue != 'Other') {
                      _categoryController.clear();
                    }
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              // Show text field only if 'Other' category is selected.
              if (_selectedCategory == 'Other')
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Specify Category'),
                  validator: (value) {
                    if (_selectedCategory == 'Other' && (value == null || value.isEmpty)) {
                      return 'Please specify category';
                    }
                    return null;
                  },
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_expiryDate == null
                    ? 'No Expiry Date Set'
                    : 'Expires: ${DateFormat.yMMMd().format(_expiryDate!)}'),
                trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                onTap: _pickExpiryDate,
              ),
              if (_expiryDate != null)
                TextButton(
                  onPressed: () => setState(() => _expiryDate = null),
                  child: const Text('Clear Expiry Date', style: TextStyle(color: Colors.grey)),
                ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                maxLines: 2,
              ),
              // Expiry reminder options, shown if an expiry date is set.
              if (_expiryDate != null) ...[
                const SizedBox(height: 16),
                Text('Reminder for Expiry:', style: Theme.of(context).textTheme.titleSmall),
                Wrap(
                  spacing: 8.0,
                  children: <Widget>[
                    ChoiceChip(
                      label: const Text('1 week before'),
                      selected: _selectedReminder == '1_week',
                      onSelected: (bool selected) {
                        setState(() { _selectedReminder = selected ? '1_week' : null; });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('1 month before'),
                      selected: _selectedReminder == '1_month',
                      onSelected: (bool selected) {
                        setState(() { _selectedReminder = selected ? '1_month' : null; });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Custom'),
                      selected: _selectedReminder == 'custom',
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedReminder = selected ? 'custom' : null;
                          // TODO: Implement custom reminder date picker for 'custom' option.
                          if (selected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Custom reminder selection TBD.')),
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveItem,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(widget.item == null ? 'Add Item' : 'Save Changes'),
        ),
      ],
    );
  }
}