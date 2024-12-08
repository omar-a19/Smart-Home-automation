import 'package:cloud_firestore/cloud_firestore.dart';

class Device {
  final String id;
  final String name;
  final String type;
  final bool status;
  final String roomId;
  final String? imageUrl;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.roomId,
    this.imageUrl,
  });

  factory Device.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Device(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      status: data['status'] ?? false,
      roomId: data['roomId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}
