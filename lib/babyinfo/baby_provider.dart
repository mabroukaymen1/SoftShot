import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BabyProvider extends ChangeNotifier {
  String? _currentBabyId;

  String? get currentBabyId => _currentBabyId;
  Future<String> addNewBaby({
    required String name,
    required String gender,
    required DateTime birthDate,
    required String relationship,
    File? profileImage,
    required Color selectedColor,
    required bool isEarlyLateBirth,
  }) async {
    try {
      // Add baby data to Firestore
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('babies').add({
        'name': name,
        'gender': gender,
        'birthDate': Timestamp.fromDate(birthDate),
        'relationship': relationship,
        'selectedColor': selectedColor.value,
        'isEarlyLateBirth': isEarlyLateBirth,
      });

      // If there's a profile image, upload it to Firebase Storage

      return docRef.id;
    } catch (e) {
      print('Error adding new baby: $e');
      throw Exception('Failed to add new baby');
    }
  }

  void setCurrentBabyId(String id) {
    _currentBabyId = id;
    notifyListeners();
  }
}
