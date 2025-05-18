import 'package:anapurna_app/resto-side/auth/location.dart';
import 'package:flutter/material.dart';

class RestaurantProfile extends StatefulWidget {
  @override
  _RestaurantProfileState createState() => _RestaurantProfileState();
}

class _RestaurantProfileState extends State<RestaurantProfile> {
  int _adClickCounter = 0;
  final int _adFrequency = 2; // Show ad every 2 clicks

  // Restaurant profile data
  String restaurantName = 'Spice Garden Restaurant';
  String phoneNumber = '+91 9876543210';
  String emailAddress = 'contact@spicegarden.com';
  String website = 'www.spicegarden.com';
  String address = '123 Main Street, Food District, Bangalore - 560001';
  String cuisineTypes = 'North Indian, South Indian, Chinese';

  @override
  void initState() {
    super.initState();
  }

  // Edit restaurant name using dialog
  void _editRestaurantName() {
    final TextEditingController controller = TextEditingController(
      text: restaurantName,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Restaurant Name'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter restaurant name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  restaurantName = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  // Edit phone number using dialog
  void _editPhoneNumber() {
    final TextEditingController controller = TextEditingController(
      text: phoneNumber,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Phone Number'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  phoneNumber = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  // Edit email address using dialog
  void _editEmailAddress() {
    final TextEditingController controller = TextEditingController(
      text: emailAddress,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Email Address'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter email address',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  emailAddress = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  // Edit website using dialog
  void _editWebsite() {
    final TextEditingController controller = TextEditingController(
      text: website,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Website'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter website',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  website = controller.text;
                });
                Navigator.pop(context);
              },
              child: Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  // Edit cuisine types using dialog with multiple options
  void _editCuisineTypes() {
    final List<String> availableCuisines = [
      'North Indian',
      'South Indian',
      'Chinese',
      'Italian',
      'Continental',
      'Thai',
      'Mexican',
      'Japanese',
      'Korean',
      'Lebanese',
    ];

    // Parse current selections into a list
    final List<String> selectedCuisines = cuisineTypes.split(', ');

    // Create a map to track selections
    final Map<String, bool> cuisineSelections = {
      for (String cuisine in availableCuisines)
        cuisine: selectedCuisines.contains(cuisine),
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Cuisine Types'),
              content: Container(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children:
                      availableCuisines.map((cuisine) {
                        return CheckboxListTile(
                          title: Text(cuisine),
                          value: cuisineSelections[cuisine],
                          onChanged: (bool? value) {
                            setState(() {
                              cuisineSelections[cuisine] = value ?? false;
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    final List<String> newSelections =
                        cuisineSelections.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .toList();

                    this.setState(() {
                      cuisineTypes = newSelections.join(', ');
                    });
                    Navigator.pop(context);
                  },
                  child: Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileInfoRow(
    IconData icon,
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Restaurant Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            _buildProfileInfoRow(
              Icons.store,
              'Restaurant Name',
              restaurantName,
              onTap: _editRestaurantName,
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.phone,
              'Phone Number',
              phoneNumber,
              onTap: _editPhoneNumber,
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.email,
              'Email Address',
              emailAddress,
              onTap: _editEmailAddress,
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.language,
              'Website',
              website,
              onTap: _editWebsite,
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.location_on,
              'Restaurant Address',
              address,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoogleMapSearchPlacesApi(),
                  ),
                );
              },
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.category,
              'Cuisine Type',
              cuisineTypes,
              onTap: _editCuisineTypes,
            ),
          ],
        ),
      ),
    );
  }
}
