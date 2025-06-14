import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // intl
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/stockpile_item.dart';
// import '../../services/firestore_service.dart'; // old
import '../../services/stockpile_repository.dart'; // new

class AddEditStockpileItemDialog extends StatefulWidget {
  final StockpileItem? item;

  const AddEditStockpileItemDialog({super.key, this.item});

  @override
  State<AddEditStockpileItemDialog> createState() => _AddEditStockpileItemDialogState();
}

class _AddEditStockpileItemDialogState extends State<AddEditStockpileItemDialog> {
  final _formKey = GlobalKey<FormState>();
  // final FirestoreService _firestoreService = FirestoreService(); // old
  final StockpileRepository _stockpileRepository = StockpileRepository.instance; // new
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  DateTime? _expiryDate;
  String? _selectedReminder;

  bool _isLoading = false;

  final List<String> _categories = [
    'Food', 'Water', 'First Aid', 'Tools', 'Documents', 'Medication', 'Sanitation', 'Other'
  ];
  String? _selectedCategory;

  // all units
  final List<String> _allUnits = ['pcs', 'kg', 'g', 'L', 'mL', 'can', 'bottle', 'box', 'roll', 'tube', 'kit', 'set', 'other'];
  // filtered units
  List<String> _filteredUnits = [];
  String? _selectedUnit;

  // new controllers
  late TextEditingController _volumePerUnitController; // water: 'bottle', 'can'
  late TextEditingController _foodTotalDaysSupplyController; // food: 'kg', 'g', 'pcs', 'can', 'bottle', 'box'

  static const double dailyWaterNeedPerPerson = 3.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '1');
    _unitController = TextEditingController(text: widget.item?.unit ?? ''); // for 'other' unit
    _categoryController = TextEditingController(text: widget.item?.category ?? ''); // for 'Other' category
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _expiryDate = widget.item?.expiryDate;
    _selectedReminder = widget.item?.reminderPreference;

    _selectedCategory = widget.item?.category;
    _selectedUnit = widget.item?.unit;

    // init new controllers
    _volumePerUnitController = TextEditingController(text: widget.item?.unitVolumeLiters?.toString() ?? '');
    _foodTotalDaysSupplyController = TextEditingController(text: widget.item?.totalDaysOfSupplyPerItem?.toString() ?? '');


    if (_selectedCategory == null && _categories.isNotEmpty) {
      _selectedCategory = _categories[0];
    }
    // initial unit filter
    _updateFilteredUnits();


    // if editing item with non-default unit, add to _allUnits
    if (_selectedUnit != null && !_allUnits.contains(_selectedUnit!)) {
      _allUnits.add(_selectedUnit!);
      _updateFilteredUnits(); // re-filter
    }
     // if editing, ensure current unit is selectable
    if (_selectedUnit != null && !_filteredUnits.contains(_selectedUnit!)) {
        // this implies unit might be valid but not in initial list
        // ensure _selectedUnit is part of dropdown
    }


    if (_selectedCategory != null && !_categories.contains(_selectedCategory!)) {
      _categories.add(_selectedCategory!);
    }
  }

  void _updateFilteredUnits() {
    setState(() {
      if (_selectedCategory == 'Food') {
        _filteredUnits = ['kg', 'g', 'pcs', 'can', 'bottle', 'box', 'other'];
      } else if (_selectedCategory == 'Water') {
        _filteredUnits = ['L', 'mL', 'bottle', 'can', 'other'];
      } else {
        // other categories: show all units
        _filteredUnits = List.from(_allUnits); // show all
      }

      // ensure 'other' is always an option
      if (!_filteredUnits.contains('other')) {
        _filteredUnits.add('other');
      }

      // if selected unit invalid for new category, reset
      if (_selectedUnit != null && !_filteredUnits.contains(_selectedUnit!)) {
        _selectedUnit = null;
        _unitController.clear(); // clear custom unit
      }
      // if 'other' selected, keep it.
    });
  }


  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _volumePerUnitController.dispose(); // dispose controller
    _foodTotalDaysSupplyController.dispose(); // dispose controller
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

      final int quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
      final String currentCategory = _selectedCategory ?? _categoryController.text.trim();
      final String? currentUnit = _selectedUnit == 'other' ? _unitController.text.trim() : _selectedUnit;

      double? unitVolumeLitersValue;
      double? totalDaysOfSupplyPerItemValue;

      // calculations by category and unit
      if (currentCategory == 'Water') {
        if (currentUnit == 'L') {
          unitVolumeLitersValue = 1.0; // 1L unit volume
        } else if (currentUnit == 'mL') {
          unitVolumeLitersValue = 0.001; // 1mL unit volume
        } else if (['bottle', 'can'].contains(currentUnit)) {
          unitVolumeLitersValue = double.tryParse(_volumePerUnitController.text.trim());
        }

        if (unitVolumeLitersValue != null && unitVolumeLitersValue > 0) {
          totalDaysOfSupplyPerItemValue = (unitVolumeLitersValue * quantity) / dailyWaterNeedPerPerson;
        } else if (['bottle', 'can'].contains(currentUnit)) {
            // if volume per unit required but not provided
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Please enter a valid volume per unit for water containers.'), backgroundColor: Colors.red),
             );
             setState(() { _isLoading = false; });
             return;
        }
      } else if (currentCategory == 'Food') {
        // food: user inputs total days supply
        if (['kg', 'g', 'pcs', 'can', 'bottle', 'box'].contains(currentUnit)) {
            totalDaysOfSupplyPerItemValue = double.tryParse(_foodTotalDaysSupplyController.text.trim());
            if (totalDaysOfSupplyPerItemValue == null || totalDaysOfSupplyPerItemValue <= 0) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Please enter valid days of supply for food items.'), backgroundColor: Colors.red),
                 );
                 setState(() { _isLoading = false; });
                 return;
            }
        }
        // unitVolumeLitersValue remains null
      }

      final newItem = StockpileItem(
        id: widget.item?.id,
        name: _nameController.text.trim(),
        quantity: quantity,
        unit: currentUnit,
        category: currentCategory,
        expiryDate: _expiryDate,
        reminderPreference: _selectedReminder,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        addedDate: widget.item?.addedDate ?? DateTime.now(),
        updatedAt: DateTime.now(), // repo sets this
        userId: userId,
        unitVolumeLiters: unitVolumeLitersValue, // calculated or input
        totalDaysOfSupplyPerItem: totalDaysOfSupplyPerItemValue, // calculated or input
        syncStatus: 'pending_sync', // repo sets this
      );

      try {
        if (widget.item == null) {
          // await _firestoreService.addStockpileItem(newItem); // old
          await _stockpileRepository.create(newItem); // new
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item added successfully!')),
          );
        } else {
          // await _firestoreService.updateStockpileItem(newItem); // old
          await _stockpileRepository.update(newItem); // new
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item updated successfully!')),
          );
        }
        Navigator.of(context).pop();
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
              // unit input: dropdown for predefined, text field for 'other'
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: _filteredUnits.map((String unit) { // from _units to _filteredUnits
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedUnit = newValue;
                          if (newValue != 'other') {
                            _unitController.clear();
                          }
                        });
                      },
                      // unit validation optional
                    ),
                  ),
                  // show text field if 'other' unit selected
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
                    _updateFilteredUnits(); // update units based on category
                    // clear specific input fields
                    _volumePerUnitController.clear();
                    _foodTotalDaysSupplyController.clear();
                    if (newValue != 'Other') {
                      _categoryController.clear();
                    }
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              // show text field if 'Other' category selected
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

              // conditional TextFormField for Water volume/unit
              if (_selectedCategory == 'Water' && (_selectedUnit == 'bottle' || _selectedUnit == 'can'))
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: _volumePerUnitController,
                    decoration: const InputDecoration(labelText: 'Volume per unit (Liters)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter volume per unit';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Please enter a valid positive volume';
                      }
                      return null;
                    },
                  ),
                ),

              // conditional TextFormField for Food days supply/unit
              if (_selectedCategory == 'Food' &&
                  (_selectedUnit == 'kg' || _selectedUnit == 'g' || _selectedUnit == 'pcs' || _selectedUnit == 'can' || _selectedUnit == 'bottle' || _selectedUnit == 'box'))
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: _foodTotalDaysSupplyController,
                    decoration: const InputDecoration(labelText: 'Days of supply per item quantity'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter days of supply';
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Please enter valid positive days of supply';
                      }
                      return null;
                    },
                  ),
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
              // expiry reminder options
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
                          // TODO: custom reminder date picker.
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