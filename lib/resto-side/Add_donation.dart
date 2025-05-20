import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import './donation_model.dart';

class AddDonationForm extends StatefulWidget {
  final Function(FoodDonation) onSubmit;
  final FoodDonation? donation; // Fixed variable naming convention (lowercase)

  AddDonationForm({super.key, required this.onSubmit, this.donation});

  @override
  _AddDonationFormState createState() => _AddDonationFormState();
}

class _AddDonationFormState extends State<AddDonationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _expiryTimeController = TextEditingController();

  DateTime _selectedExpiryDate = DateTime.now().add(Duration(hours: 4));
  String _selectedFoodType = 'Vegetarian';
  File? _selectedImage; // Store the selected image file
  bool _isSubmitting = false;

  List<String> foodTypes = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Dessert',
    'Packed',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.donation != null) {
      // Populate form with existing donation data for editing
      _foodNameController.text = widget.donation!.foodName;
      _quantityController.text = widget.donation!.quantity;
      _selectedExpiryDate = widget.donation!.expiry;
      _selectedFoodType = widget.donation!.foodType;

      // Set date and time controllers
      _expiryDateController.text = DateFormat(
        'MMM d, yyyy',
      ).format(_selectedExpiryDate);
      _expiryTimeController.text = DateFormat(
        'hh:mm a',
      ).format(_selectedExpiryDate);
    } else {
      // Set default date and time for new donations
      _expiryDateController.text = DateFormat(
        'MMM d, yyyy',
      ).format(_selectedExpiryDate);
      _expiryTimeController.text = DateFormat(
        'hh:mm a',
      ).format(_selectedExpiryDate);
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    _expiryTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedExpiryDate.hour,
          _selectedExpiryDate.minute,
        );
        _expiryDateController.text = DateFormat(
          'MMM d, yyyy',
        ).format(_selectedExpiryDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedExpiryDate),
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = DateTime(
          _selectedExpiryDate.year,
          _selectedExpiryDate.month,
          _selectedExpiryDate.day,
          picked.hour,
          picked.minute,
        );
        _expiryTimeController.text = DateFormat(
          'hh:mm a',
        ).format(_selectedExpiryDate);
      });
    }
  }

  Future<void> _getImage() async {
    final ImagePicker picker = ImagePicker();

    // Show an options dialog for camera or gallery
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (photo != null) {
                    setState(() {
                      _selectedImage = File(photo.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Check if image is selected
      if (_selectedImage == null && widget.donation?.imageUrl == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please select a food image')));
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      // In a real app, you would upload the image to a server and get back a URL
      // For this example, we'll just use the local file path
      String imageUrl = _selectedImage?.path ?? widget.donation?.imageUrl ?? '';

      // Create donation object
      final FoodDonation newDonation = FoodDonation(
        id:
            widget.donation?.id ??
            'DON-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 4)}',
        foodName: _foodNameController.text,
        quantity: _quantityController.text,
        expiry: _selectedExpiryDate,
        status: 'Available',
        foodType: _selectedFoodType,
        imageUrl: imageUrl,
        donorName: 'Spice Garden Restaurant', // Hard-coded for example
        createdAt: widget.donation?.createdAt ?? DateTime.now(),
      );

      // Submit the donation to parent
      widget.onSubmit(newDonation);

      // Close the form
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Form title and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.donation == null
                          ? 'Add Food Donation'
                          : 'Edit Food Donation',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Food image
                Center(
                  child: GestureDetector(
                    onTap: _getImage,
                    child: Stack(
                      children: [
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            image:
                                _selectedImage != null
                                    ? DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                    : widget.donation?.imageUrl != null &&
                                        widget.donation!.imageUrl.startsWith(
                                          'http',
                                        )
                                    ? DecorationImage(
                                      image: NetworkImage(
                                        widget.donation!.imageUrl,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                    : widget.donation?.imageUrl != null
                                    ? DecorationImage(
                                      image: FileImage(
                                        File(widget.donation!.imageUrl),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              _selectedImage == null &&
                                      widget.donation?.imageUrl == null
                                  ? Icon(
                                    Icons.add_a_photo,
                                    color: Colors.grey[500],
                                    size: 40,
                                  )
                                  : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Food name
                TextFormField(
                  controller: _foodNameController,
                  decoration: InputDecoration(
                    labelText: 'Food Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant_menu),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter food name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Quantity
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity (e.g., 5 kg, 20 pieces)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.scale),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Food Type
                DropdownButtonFormField<String>(
                  value: _selectedFoodType,
                  decoration: InputDecoration(
                    labelText: 'Food Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items:
                      foodTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedFoodType = newValue;
                      });
                    }
                  },
                ),
                SizedBox(height: 16),

                // Expiry Date and Time
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _expiryDateController,
                            decoration: InputDecoration(
                              labelText: 'Expiry Date',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _expiryTimeController,
                            decoration: InputDecoration(
                              labelText: 'Expiry Time',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select time';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    child:
                        _isSubmitting
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              widget.donation == null
                                  ? 'Add Donation'
                                  : 'Update Donation',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
