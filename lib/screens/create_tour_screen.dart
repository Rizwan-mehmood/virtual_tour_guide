import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tour_model.dart';
import '../models/exhibit_model.dart';
import '../providers/firebase_provider.dart';
import '../theme.dart';
import 'exhibit_selection_screen.dart';

class CreateTourScreen extends StatefulWidget {
  final DateTime? initialDate;
  final Tour? tourToEdit;

  const CreateTourScreen({Key? key, this.initialDate, this.tourToEdit})
    : super(key: key);

  @override
  State<CreateTourScreen> createState() => _CreateTourScreenState();
}

class _CreateTourScreenState extends State<CreateTourScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<TourExhibit> _selectedExhibits = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Set initial values if editing a tour
    if (widget.tourToEdit != null) {
      _titleController.text = widget.tourToEdit!.title;
      _descriptionController.text = widget.tourToEdit!.description;
      _durationController.text = widget.tourToEdit!.durationMinutes.toString();
      _selectedDate = widget.tourToEdit!.tourDate;
      _selectedTime = TimeOfDay(
        hour: widget.tourToEdit!.tourDate.hour,
        minute: widget.tourToEdit!.tourDate.minute,
      );
      _selectedExhibits = List.from(widget.tourToEdit!.exhibits);
    } else if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }

    // Set default duration if not editing
    if (widget.tourToEdit == null) {
      _durationController.text = '60';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _navigateToExhibitSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ExhibitSelectionScreen(initialExhibits: _selectedExhibits),
      ),
    );

    if (result != null && result is List<TourExhibit>) {
      setState(() {
        _selectedExhibits = result;
      });
    }
  }

  Future<void> _saveTour() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExhibits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one exhibit'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final firebaseProvider = Provider.of<FirebaseProvider>(
        context,
        listen: false,
      );
      final currentUser = firebaseProvider.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Combine date and time
      final tourDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final tour = Tour(
        id: widget.tourToEdit?.id ?? '',
        userId: currentUser.uid,
        title: _titleController.text,
        description: _descriptionController.text,
        tourDate: tourDateTime,
        exhibits: _selectedExhibits,
        createdAt: widget.tourToEdit?.createdAt ?? DateTime.now(),
        durationMinutes: int.parse(_durationController.text),
      );

      if (widget.tourToEdit != null) {
        await firebaseProvider.updateTour(tour);
      } else {
        await firebaseProvider.createTour(tour);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving tour: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.tourToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Tour' : 'Create Tour')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tour Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Tour Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date and Time selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration field
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a duration';
                  }
                  try {
                    final duration = int.parse(value);
                    if (duration <= 0) {
                      return 'Duration must be positive';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Exhibits section
              const Text(
                'Exhibits',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Exhibits list or add button
              if (_selectedExhibits.isEmpty)
                Card(
                  elevation: 0,
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: InkWell(
                    onTap: _navigateToExhibitSelection,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_circle_outline,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add Exhibits to Tour',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedExhibits.length,
                      itemBuilder: (context, index) {
                        final exhibit = _selectedExhibits[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text((index + 1).toString()),
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            title: Text(exhibit.name),
                            subtitle: Text(
                              '${exhibit.visitDurationMinutes} mins',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedExhibits.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _navigateToExhibitSelection,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Exhibits'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _saveTour,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isProcessing
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : Text(isEditing ? 'Update Tour' : 'Create Tour'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
