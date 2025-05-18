class FoodDonation {
  final String id;
  final String foodName;
  final String quantity;
  final DateTime expiry;
  String status;
  final String foodType;
  final String? ngoName;
  final DateTime? pickupTime;
  final String imageUrl;
  final String donorName;
  final DateTime createdAt;

  FoodDonation({
    required this.id,
    required this.foodName,
    required this.quantity,
    required this.expiry,
    required this.status,
    required this.foodType,
    this.ngoName,
    this.pickupTime,
    required this.imageUrl,
    required this.donorName,
    required this.createdAt,
  });

  // Convert to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'quantity': quantity,
      'expiry': expiry.millisecondsSinceEpoch,
      'status': status,
      'foodType': foodType,
      'ngoName': ngoName,
      'pickupTime': pickupTime?.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'donorName': donorName,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from a Map from storage
  factory FoodDonation.fromMap(Map<String, dynamic> map) {
    return FoodDonation(
      id: map['id'],
      foodName: map['foodName'],
      quantity: map['quantity'],
      expiry: DateTime.fromMillisecondsSinceEpoch(map['expiry']),
      status: map['status'],
      foodType: map['foodType'],
      ngoName: map['ngoName'],
      pickupTime:
          map['pickupTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(map['pickupTime'])
              : null,
      imageUrl: map['imageUrl'],
      donorName: map['donorName'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create a copy with updated fields
  FoodDonation copyWith({
    String? id,
    String? foodName,
    String? quantity,
    DateTime? expiry,
    String? status,
    String? foodType,
    String? ngoName,
    DateTime? pickupTime,
    String? imageUrl,
    String? donorName,
    DateTime? createdAt,
  }) {
    return FoodDonation(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      expiry: expiry ?? this.expiry,
      status: status ?? this.status,
      foodType: foodType ?? this.foodType,
      ngoName: ngoName ?? this.ngoName,
      pickupTime: pickupTime ?? this.pickupTime,
      imageUrl: imageUrl ?? this.imageUrl,
      donorName: donorName ?? this.donorName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
