import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Room>> getRoomsByUserId(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('rooms')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load rooms');
    }
  }
}