import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformModel {
  final String id;
  final String platformName;
  final String username;
  final String url;
  final bool isConnected;

  PlatformModel({
    required this.id,
    required this.platformName,
    required this.username,
    required this.url,
    required this.isConnected,
  });

  factory PlatformModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlatformModel(
      id: doc.id,
      platformName: data['platformName'] ?? '',
      username: data['username'] ?? '',
      url: data['url'] ?? '',
      isConnected: data['isConnected'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'platformName': platformName,
      'username': username,
      'url': url,
      'isConnected': isConnected,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
