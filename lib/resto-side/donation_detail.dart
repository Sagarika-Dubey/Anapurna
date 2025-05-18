import 'package:flutter/material.dart';

class DonationDetail extends StatelessWidget {
  final dynamic donation;

  const DonationDetail({Key? key, required this.donation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donation Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Donation image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(donation.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Donation details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(donation.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      donation.status,
                      style: TextStyle(
                        color: _getStatusColor(donation.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Food name
                  Text(
                    donation.foodName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 8),

                  // Food type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      donation.foodType,
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Details list
                  _buildDetailRow(
                    Icons.inventory_2,
                    'Quantity',
                    donation.quantity,
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.timer,
                    'Expires',
                    _formatDateTime(donation.expiry),
                  ),
                  SizedBox(height: 16),
                  _buildDetailRow(Icons.store, 'Donor', donation.donorName),
                  SizedBox(height: 16),
                  _buildDetailRow(
                    Icons.confirmation_number,
                    'Donation ID',
                    donation.id,
                  ),

                  if (donation.ngoName != null) ...[
                    SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.business,
                      'NGO Partner',
                      donation.ngoName!,
                    ),
                  ],

                  if (donation.pickupTime != null) ...[
                    SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.delivery_dining,
                      'Pickup Time',
                      _formatDateTime(donation.pickupTime!),
                    ),
                  ],

                  SizedBox(height: 32),

                  // Action buttons based on status
                  if (donation.status == 'Available') ...[
                    _buildActionButtons(context),
                  ],

                  if (donation.status == 'Confirmed') ...[
                    _buildConfirmedActions(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Edit functionality
              Navigator.pop(context, 'edit');
            },
            icon: Icon(Icons.edit),
            label: Text('Edit'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Cancel functionality
              Navigator.pop(context, 'cancel');
            },
            icon: Icon(Icons.cancel),
            label: Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmedActions(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Contact NGO functionality
          Navigator.pop(context, 'contact');
        },
        icon: Icon(Icons.contact_phone),
        label: Text('Contact NGO'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
