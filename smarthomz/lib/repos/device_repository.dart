import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device.dart';
import '../models/room.dart';

class DeviceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Device>> getDevices() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('devices').get();
      return snapshot.docs.map((doc) => Device.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load devices');
    }
  }

  Future<List<Room>> getRooms() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('rooms').get();
      return snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load rooms');
    }
  }

  Future<List<Device>> getDevicesByRoom(String roomId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('devices')
          .where('roomId', isEqualTo: roomId)
          .get();
      return snapshot.docs.map((doc) => Device.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to load devices for room');
    }
  }

  Future<void> updateDevice(String deviceId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('devices').doc(deviceId).update(updates);
    } catch (e) {
      throw Exception('Failed to update device');
    }
  }
}
