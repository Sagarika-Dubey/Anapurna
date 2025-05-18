import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './donation_model.dart';

class DonationProvider with ChangeNotifier {
  List<FoodDonation> _activeDonations = [];
  List<FoodDonation> _pastDonations = [];

  List<FoodDonation> get activeDonations => _activeDonations;
  List<FoodDonation> get pastDonations => _pastDonations;

  DonationProvider() {
    loadDonations();
  }

  // Load donations from SharedPreferences
  Future<void> loadDonations() async {
    final prefs = await SharedPreferences.getInstance();

    // Load active donations
    final activeJson = prefs.getStringList('activeDonations') ?? [];
    _activeDonations =
        activeJson
            .map((json) => FoodDonation.fromMap(jsonDecode(json)))
            .toList();

    // Load past donations
    final pastJson = prefs.getStringList('pastDonations') ?? [];
    _pastDonations =
        pastJson.map((json) => FoodDonation.fromMap(jsonDecode(json))).toList();

    // Check for expired donations and move them
    refreshDonations();

    notifyListeners();
  }

  // Save donations to SharedPreferences
  Future<void> saveDonations() async {
    final prefs = await SharedPreferences.getInstance();

    // Save active donations
    final activeJson =
        _activeDonations
            .map((donation) => jsonEncode(donation.toMap()))
            .toList();
    await prefs.setStringList('activeDonations', activeJson);

    // Save past donations
    final pastJson =
        _pastDonations.map((donation) => jsonEncode(donation.toMap())).toList();
    await prefs.setStringList('pastDonations', pastJson);
  }

  // Add a new donation
  void addDonation(FoodDonation donation) {
    _activeDonations.add(donation);
    saveDonations();
    notifyListeners();
  }

  // Update an existing donation
  void updateDonation(FoodDonation updatedDonation) {
    final index = _activeDonations.indexWhere(
      (donation) => donation.id == updatedDonation.id,
    );

    if (index != -1) {
      _activeDonations[index] = updatedDonation;
      saveDonations();
      notifyListeners();
    }
  }

  // Cancel a donation
  void cancelDonation(String donationId) {
    final donationIndex = _activeDonations.indexWhere(
      (donation) => donation.id == donationId,
    );

    if (donationIndex != -1) {
      final donation = _activeDonations[donationIndex];
      donation.status = 'Cancelled';
      _pastDonations.add(donation);
      _activeDonations.removeAt(donationIndex);
      saveDonations();
      notifyListeners();
    }
  }

  // Complete a donation
  void completeDonation(String donationId) {
    final donationIndex = _activeDonations.indexWhere(
      (donation) => donation.id == donationId,
    );

    if (donationIndex != -1) {
      final donation = _activeDonations[donationIndex];
      donation.status = 'Completed';
      _pastDonations.add(donation);
      _activeDonations.removeAt(donationIndex);
      saveDonations();
      notifyListeners();
    }
  }

  // Refresh donations and check for expired ones
  void refreshDonations() {
    final now = DateTime.now();
    final expiredDonations =
        _activeDonations
            .where(
              (donation) =>
                  donation.status == 'Available' &&
                  donation.expiry.isBefore(now),
            )
            .toList();

    for (var donation in expiredDonations) {
      donation.status = 'Expired';
      _pastDonations.add(donation);
      _activeDonations.remove(donation);
    }

    if (expiredDonations.isNotEmpty) {
      saveDonations();
      notifyListeners();
    }
  }

  // Get available donations
  List<FoodDonation> getAvailableDonations() {
    return _activeDonations
        .where((donation) => donation.status == 'Available')
        .toList();
  }

  // Get confirmed donations
  List<FoodDonation> getConfirmedDonations() {
    return _activeDonations
        .where((donation) => donation.status == 'Confirmed')
        .toList();
  }

  // Get filtered past donations
  List<FoodDonation> getFilteredPastDonations(String filter) {
    switch (filter) {
      case 'Completed':
        return _pastDonations
            .where((donation) => donation.status == 'Completed')
            .toList();
      case 'Expired':
        return _pastDonations
            .where((donation) => donation.status == 'Expired')
            .toList();
      case 'Cancelled':
        return _pastDonations
            .where((donation) => donation.status == 'Cancelled')
            .toList();
      case 'This Month':
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        return _pastDonations
            .where((donation) => donation.createdAt.isAfter(startOfMonth))
            .toList();
      default:
        return List.from(_pastDonations);
    }
  }
}
