import 'dart:io';
import 'package:anapurna_app/resto-side/auth/location.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './donation_model.dart';
import './donation_provider.dart';
import './Add_donation.dart';
import './donation_detail.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantHomePage extends StatefulWidget {
  @override
  _RestaurantHomePageState createState() => _RestaurantHomePageState();
}

class _RestaurantHomePageState extends State<RestaurantHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String selectedFilter = 'All';
  List<FoodDonation> filteredPastDonations = [];
  File? _selectedImage;

  // Sample data - in production, this would come from the DonationProvider
  final List<FoodDonation> activeDonations = [
    FoodDonation(
      id: 'DON-1001',
      foodName: 'Mixed Vegetable Curry',
      quantity: '5 kg',
      expiry: DateTime.now().add(Duration(hours: 5)),
      status: 'Available',
      foodType: 'Vegetarian',
      imageUrl: 'assest/istockphoto-673858790-612x612.jpg',
      donorName: 'Spice Garden Restaurant',
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    FoodDonation(
      id: 'DON-1002',
      foodName: 'Rice',
      quantity: '10 kg',
      expiry: DateTime.now().add(Duration(hours: 6)),
      status: 'Confirmed',
      foodType: 'Vegetarian',
      ngoName: 'Happy Hearts NGO',
      pickupTime: DateTime.now().add(Duration(hours: 2)),
      imageUrl: 'assest/istockphoto-673858790-612x612.jpg',
      donorName: 'Spice Garden Restaurant',
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
    ),
  ];

  final List<FoodDonation> allPastDonations = [
    FoodDonation(
      id: 'DON-0998',
      foodName: 'Dal Makhani',
      quantity: '7 kg',
      expiry: DateTime.now().subtract(Duration(days: 1)),
      status: 'Completed',
      foodType: 'Vegetarian',
      ngoName: 'Helping Hands Foundation',
      pickupTime: DateTime.now().subtract(Duration(days: 1, hours: 5)),
      imageUrl: 'assest/istockphoto-673858790-612x612.jpg',
      donorName: 'Spice Garden Restaurant',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
    ),
    FoodDonation(
      id: 'DON-0997',
      foodName: 'Naan',
      quantity: '50 pieces',
      expiry: DateTime.now().subtract(Duration(days: 2)),
      status: 'Completed',
      foodType: 'Vegetarian',
      ngoName: 'Food For All',
      pickupTime: DateTime.now().subtract(Duration(days: 2, hours: 3)),
      imageUrl: 'assest/istockphoto-673858790-612x612.jpg',
      donorName: 'Spice Garden Restaurant',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    FoodDonation(
      id: 'DON-0996',
      foodName: 'Paneer Butter Masala',
      quantity: '4 kg',
      expiry: DateTime.now().subtract(Duration(days: 5)),
      status: 'Expired',
      foodType: 'Vegetarian',
      imageUrl: 'assest/istockphoto-673858790-612x612.jpg',
      donorName: 'Spice Garden Restaurant',
      createdAt: DateTime.now().subtract(Duration(days: 6)),
    ),
    FoodDonation(
      id: 'DON-0995',
      foodName: 'Vegetable Biryani',
      quantity: '8 kg',
      expiry: DateTime.now().subtract(Duration(days: 10)),
      status: 'Completed',
      foodType: 'Vegetarian',
      ngoName: 'Care Foundation',
      pickupTime: DateTime.now().subtract(Duration(days: 10, hours: 4)),
      imageUrl: 'assest/istockphoto-673858790-612x612.jpg',
      donorName: 'Spice Garden Restaurant',
      createdAt: DateTime.now().subtract(Duration(days: 11)),
    ),
    FoodDonation(
      id: 'DON-0994',
      foodName: 'Chicken Curry',
      quantity: '6 kg',
      expiry: DateTime.now().subtract(Duration(days: 15)),
      status: 'Completed',
      foodType: 'Non-Vegetarian',
      ngoName: 'Hope Trust',
      pickupTime: DateTime.now().subtract(Duration(days: 15, hours: 2)),
      imageUrl: 'assest/istockphoto-673858790-612x612.jpg',
      donorName: 'Spice Garden Restaurant',
      createdAt: DateTime.now().subtract(Duration(days: 16)),
    ),
    FoodDonation(
      id: 'DON-0993',
      foodName: 'Roti',
      quantity: '30 pieces',
      expiry: DateTime.now().subtract(Duration(days: 20)),
      status: 'Cancelled',
      foodType: 'Vegetarian',
      imageUrl: 'assest/istockphoto-673858790-612x612.jpg',
      donorName: 'Spice Garden Restaurant',
      createdAt: DateTime.now().subtract(Duration(days: 21)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize filtered donations with all past donations
    filteredPastDonations = List.from(allPastDonations);

    // Refresh donations when screen loads to check for expired items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // In production, use Provider instead of this local data
      // Provider.of<DonationProvider>(context, listen: false).refreshDonations();
      refreshDonations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method to refresh donations and check for expired items
  void refreshDonations() {
    setState(() {
      // Check for expired items in activeDonations and move them to history
      final now = DateTime.now();
      final expiredDonations =
          activeDonations
              .where(
                (donation) =>
                    donation.status == 'Available' &&
                    donation.expiry.isBefore(now),
              )
              .toList();

      for (var donation in expiredDonations) {
        donation.status = 'Expired';
        allPastDonations.add(donation);
        activeDonations.remove(donation);
      }

      // Re-apply current filter
      _applyFilter(selectedFilter);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assest/logo.png', height: 32),
            SizedBox(width: 8),
            Text('Anapurna', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage('assest/app-back-page.png'),
            ),
            onPressed: () {
              // Navigate to profile page
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  _showAddDonationForm(context);
                },
                child: Icon(Icons.add),
                tooltip: 'Add Donation',
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildHistoryPage();
      case 2:
        return _buildProfilePage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(text: 'Active'),
            Tab(text: 'Claimed'),
            Tab(text: 'History'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDonationList('Active'),
              _buildDonationList('Claimed'),
              _buildDonationList('History'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonationList(String listType) {
    List<FoodDonation> donations = [];

    // Get appropriate donations based on tab
    if (listType == 'Active') {
      donations =
          activeDonations.where((d) => d.status == 'Available').toList();
    } else if (listType == 'Claimed') {
      donations =
          activeDonations.where((d) => d.status == 'Confirmed').toList();
    } else {
      // History shows both completed and expired
      donations =
          allPastDonations
              .where(
                (d) =>
                    d.status == 'Completed' ||
                    d.status == 'Expired' ||
                    d.status == 'Cancelled',
              )
              .toList();
    }

    // Sort by newest first
    donations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (donations.isEmpty) {
      return _buildEmptyState(listType);
    }

    return RefreshIndicator(
      onRefresh: () async {
        refreshDonations();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listType == 'Active') _buildWelcomeCard(),

            SizedBox(height: 16),
            if (listType == 'Active')
              Text(
                'Active Donations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            if (listType == 'Claimed')
              Text(
                'Claimed Donations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            if (listType == 'History')
              Text(
                'Past Donations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                return listType == 'History'
                    ? _buildHistoryDonationCard(donations[index])
                    : _buildDonationCard(donations[index]);
              },
            ),

            // Show impact stats at the bottom of active tab
            if (listType == 'Active') ...[
              SizedBox(height: 24),
              Text(
                'Impact Stats',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _buildImpactStatsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String listType) {
    IconData iconData;
    String message;

    if (listType == 'Active') {
      iconData = Icons.inventory_2_outlined;
      message = 'No active donations yet';
    } else if (listType == 'Claimed') {
      iconData = Icons.delivery_dining_outlined;
      message = 'No claimed donations yet';
    } else {
      iconData = Icons.history_outlined;
      message = 'No completed donations yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          if (listType == 'Active')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showAddDonationForm(context);
                },
                icon: Icon(Icons.add),
                label: Text('Add Donation'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Color(0xFFFF9800)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assest/app-back-page.png'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        'Spice Garden Restaurant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Thank you for reducing food waste and helping those in need!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () {
                // Navigate to Add Food Donation page
                _showAddDonationForm(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Donate Excess Food',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationCard(FoodDonation donation) {
    final isAvailable = donation.status == 'Available';
    final isConfirmed = donation.status == 'Confirmed';
    final bool isExpiringSoon =
        isAvailable && donation.expiry.difference(DateTime.now()).inHours < 2;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to detail screen
          _showDonationDetailsDialog(context, donation);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator for claimed donations
            if (isConfirmed)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Text(
                  donation.status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Food image or placeholder
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    isAvailable
                        ? BorderRadius.vertical(top: Radius.circular(12))
                        : BorderRadius.zero,
                image: DecorationImage(
                  image: AssetImage(donation.imageUrl),
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[200],
              ),
            ),

            // Food details
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          donation.foodName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          donation.foodType,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Quantity: ${donation.quantity}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: isExpiringSoon ? Colors.red : Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Expires: ${_formatExpiryTime(donation.expiry)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isExpiringSoon ? Colors.red : Colors.grey[700],
                          fontWeight:
                              isExpiringSoon
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          donation.donorName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  if (isConfirmed) ...[
                    Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: Icon(
                          Icons.volunteer_activism,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        donation.ngoName!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Pickup: ${DateFormat('hh:mm a').format(donation.pickupTime!)}',
                      ),
                      trailing: OutlinedButton(
                        onPressed: () {
                          // Show NGO contact details
                        },
                        child: Text('Contact'),
                      ),
                    ),
                  ],

                  if (isAvailable) ...[
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Edit donation details
                              _showAddDonationForm(context, donation: donation);
                            },
                            child: Text('Edit'),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Cancel donation
                              _cancelDonation(donation);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDonationCard(FoodDonation donation) {
    Color statusColor;
    Color bgColor;

    // Determine status color
    switch (donation.status) {
      case 'Completed':
        statusColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
        break;
      case 'Expired':
        statusColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
        break;
      default:
        statusColor = Colors.orange;
        bgColor = Colors.orange.withOpacity(0.1);
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showDonationDetailsDialog(context, donation);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  donation.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          donation.foodName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            donation.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${donation.id} • ${donation.quantity}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        if (donation.ngoName != null) ...[
                          Icon(
                            Icons.business,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            donation.ngoName!,
                            style: TextStyle(fontSize: 13),
                          ),
                          Spacer(),
                        ] else
                          Spacer(),
                        Text(
                          DateFormat('MMM d, yy').format(donation.expiry),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Impact',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.restaurant,
                    value: '56 kg',
                    label: 'Food Donated',
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.people,
                    value: '225',
                    label: 'People Fed',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.volunteer_activism,
                    value: '14',
                    label: 'NGOs Helped',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 8),
            Text(
              '70% towards your monthly donation goal of 80 kg',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Method to show donation details in a dialog
  void _showDonationDetailsDialog(BuildContext context, FoodDonation donation) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: AssetImage(donation.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            donation.status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          donation.status,
                          style: TextStyle(
                            color: _getStatusColor(donation.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        donation.foodName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow('ID', donation.id),
                      _buildDetailRow('Quantity', donation.quantity),
                      _buildDetailRow('Food Type', donation.foodType),
                      _buildDetailRow(
                        'Expiry Date',
                        DateFormat(
                          'MMM d, yyyy - hh:mm a',
                        ).format(donation.expiry),
                      ),
                      _buildDetailRow(
                        'Created',
                        DateFormat(
                          'MMM d, yyyy - hh:mm a',
                        ).format(donation.createdAt),
                      ),

                      if (donation.ngoName != null)
                        _buildDetailRow('NGO Partner', donation.ngoName!),

                      if (donation.pickupTime != null)
                        _buildDetailRow(
                          'Pickup Time',
                          DateFormat(
                            'MMM d, yyyy - hh:mm a',
                          ).format(donation.pickupTime!),
                        ),

                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (donation.status == 'Available') ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _showAddDonationForm(
                                    context,
                                    donation: donation,
                                  );
                                },
                                child: Text('Edit'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _cancelDonation(donation);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text('Cancel'),
                              ),
                            ),
                          ],
                          if (donation.status == 'Confirmed') ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Show NGO contact information
                                },
                                child: Text('Contact NGO'),
                              ),
                            ),
                          ],
                          if (donation.status == 'Completed' ||
                              donation.status == 'Expired' ||
                              donation.status == 'Cancelled') ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Close'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.blue;
      case 'Confirmed':
        return Colors.green;
      case 'Completed':
        return Colors.green;
      case 'Expired':
        return Colors.red;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Method to format expiry time
  String _formatExpiryTime(DateTime expiry) {
    final now = DateTime.now();
    final difference = expiry.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    } else if (difference.inHours < 1) {
      return 'In ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'In ${difference.inHours} hours';
    } else {
      return DateFormat('MMM d, hh:mm a').format(expiry);
    }
  }

  // Cancel a donation
  void _cancelDonation(FoodDonation donation) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cancel Donation'),
            content: Text('Are you sure you want to cancel this donation?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  // In production, use Provider to update the status
                  setState(() {
                    donation.status = 'Cancelled';
                    activeDonations.remove(donation);
                    allPastDonations.add(donation);
                    filteredPastDonations = List.from(allPastDonations);
                    _applyFilter(selectedFilter);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Donation cancelled successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Yes, Cancel'),
              ),
            ],
          ),
    );
  }

  // Method to show add donation form
  void _showAddDonationForm(BuildContext context, {FoodDonation? donation}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AddDonationForm(
            donation: donation,
            onSubmit: (FoodDonation newDonation) {
              if (donation != null) {
                // Update existing donation
                setState(() {
                  int index = activeDonations.indexOf(donation);
                  if (index != -1) {
                    activeDonations[index] = newDonation;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Donation updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                // Add new donation
                setState(() {
                  activeDonations.add(newDonation);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Donation added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
    );
  }

  Widget _buildHistoryPage() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Donation History',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              // Filtering options
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Completed'),
                    _buildFilterChip('Expired'),
                    _buildFilterChip('Cancelled'),
                    _buildFilterChip('This Month'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              filteredPastDonations.isEmpty
                  ? _buildEmptyHistoryState()
                  : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredPastDonations.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryDonationCard(
                        filteredPastDonations[index],
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = label;
            _applyFilter(label);
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      // Apply the selected filter
      switch (filter) {
        case 'All':
          filteredPastDonations = List.from(allPastDonations);
          break;
        case 'Completed':
          filteredPastDonations =
              allPastDonations.where((d) => d.status == 'Completed').toList();
          break;
        case 'Expired':
          filteredPastDonations =
              allPastDonations.where((d) => d.status == 'Expired').toList();
          break;
        case 'Cancelled':
          filteredPastDonations =
              allPastDonations.where((d) => d.status == 'Cancelled').toList();
          break;
        case 'This Month':
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          filteredPastDonations =
              allPastDonations
                  .where((d) => d.createdAt.isAfter(startOfMonth))
                  .toList();
          break;
      }

      // Sort by newest first
      filteredPastDonations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Widget _buildEmptyHistoryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No donation history found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            selectedFilter != 'All'
                ? 'Try changing your filter selection'
                : 'Your completed donations will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
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

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header with profile image and cover
          Container(
            height: 160,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 60),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Color(0xFFFF9800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // Restaurant name overlay on cover
                Positioned(
                  top: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurant Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Spice Garden',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile image overlay positioned at bottom
                Positioned(
                  bottom: -50,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assest/app-back-page.png'),
                    ),
                  ),
                ),

                // Edit button for profile picture
                Positioned(
                  bottom: -30,
                  right: MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () {
                        // Photo upload functionality
                        _getImage();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Restaurant name and badge
          Text(
            'Spice Garden Restaurant',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Premium Partner',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.blue, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Top Donor',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Quick Stats
          Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickStat(
                  context: context,
                  value: '56 kg',
                  label: 'Food Donated',
                ),
                _buildVerticalDivider(),
                _buildQuickStat(
                  context: context,
                  value: '14',
                  label: 'Donations',
                ),
                _buildVerticalDivider(),
                _buildQuickStat(
                  context: context,
                  value: '14',
                  label: 'NGOs Reached',
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Profile Info Card
          _buildProfileCard(),
          SizedBox(height: 24),

          // Donation Analytics
          _buildDonationStats(),
          SizedBox(height: 24),

          // Settings Section
          _buildSettingsSection(),
          SizedBox(height: 32),

          // Logout Button with confirmation dialog
          OutlinedButton.icon(
            onPressed: () {
              _showLogoutConfirmationDialog();
            },
            icon: Icon(Icons.logout),
            label: Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required BuildContext context,
    required String value,
    required String label,
    TextStyle? valueStyle,
    TextStyle? labelStyle,
    double spacing = 4.0,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    // Use the provided styles or fallback to defaults
    final effectiveValueStyle =
        valueStyle ??
        TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        );

    final effectiveLabelStyle =
        labelStyle ?? TextStyle(fontSize: 12, color: Colors.grey[600]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          value,
          style: effectiveValueStyle,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing),
        Text(
          label,
          style: effectiveLabelStyle,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: Colors.grey[300]);
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Restaurant Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    // Edit profile functionality
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (contect) => GoogleMapSearchPlacesApi(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[100],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Edit',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildProfileInfoRow(
              Icons.store,
              'Restaurant Name',
              'Spice Garden Restaurant',
              onTap: () {
                String restaurantName = 'Spice Garden Restaurant';

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
              },
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.phone,
              'Phone Number',
              '+91 9876543210',
              onTap: () {
                // Edit phone number
                String phoneNumber = '+91 9876543210';
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
              },
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.email,
              'Email Address',
              'contact@spicegarden.com',
              onTap: () {
                // Edit email
                String emailAddress = 'contact@spicegarden.com';
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
              },
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.language,
              'Website',
              'www.spicegarden.com',
              onTap: () {
                // Edit website
                String website = 'www.spicegarden.com';
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
              },
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.location_on,
              'Restaurant Address',
              '123 Main Street, Food District, Bangalore - 560001',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (contect) => GoogleMapSearchPlacesApi(),
                  ),
                );
              },
            ),
            Divider(height: 24),
            _buildProfileInfoRow(
              Icons.category,
              'Cuisine Type',
              'North Indian, South Indian, Chinese',
              onTap: () {
                // Edit cuisine types
                String cuisineTypes = 'North Indian, South Indian, Chinese';
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
                                          cuisineSelections[cuisine] =
                                              value ?? false;
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
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(
    IconData icon,
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: Theme.of(context).primaryColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildDonationStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Donation Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'This Month',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Monthly progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Donation Goal',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '70%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      height: 16,
                      width:
                          MediaQuery.of(context).size.width *
                          0.7 *
                          0.7, // 70% of card width
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green, Colors.lightGreen],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '56 kg / 80 kg',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Donation distribution chart placeholder
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text(
                      'Donation Distribution',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // View detailed analytics button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // View detailed analytics
                },
                icon: Icon(Icons.analytics),
                label: Text('View Detailed Analytics'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings & Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.notifications_active,
              title: 'Notifications',
              subtitle: 'Configure your alerts and reminders',
              iconColor: Colors.red,
              onTap: () {
                // Navigate to notifications settings
              },
            ),
            Divider(height: 4),
            _buildSettingsItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              iconColor: Colors.blue,
              onTap: () {
                // Navigate to language settings
              },
            ),
            Divider(height: 4),
            _buildSettingsItem(
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Manage your account security settings',
              iconColor: Colors.green,
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            Divider(height: 4),
            _buildSettingsItem(
              icon: Icons.inventory_2,
              title: 'Food Categories',
              subtitle: 'Manage your available food categories',
              iconColor: Colors.orange,
              onTap: () {
                // Navigate to food categories
              },
            ),
            Divider(height: 4),
            _buildSettingsItem(
              icon: Icons.schedule,
              title: 'Operating Hours',
              subtitle: 'Set your restaurant working hours',
              iconColor: Colors.purple,
              onTap: () {
                // Navigate to working hours settings
              },
            ),
            Divider(height: 4),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs and contact support',
              iconColor: Colors.teal,
              onTap: () {
                // Navigate to help & support
              },
            ),
            Divider(height: 4),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'About Annapurna',
              subtitle: 'Learn more about our mission',
              iconColor: Colors.indigo,
              onTap: () {
                // Navigate to about page
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text('Logout'),
            content: Text('Are you sure you want to logout from your account?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle logout functionality
                  Navigator.pop(context);
                  // Add actual logout code here
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Yes, Logout'),
              ),
            ],
          ),
    );
  }
}
