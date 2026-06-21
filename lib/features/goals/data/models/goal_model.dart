import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String title;
  final String targetJob;
  final String? targetMonth;
  final String? targetYear;
  final bool isCompleted;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetJob,
    this.targetMonth,
    this.targetYear,
    required this.isCompleted,
    required this.createdAt,
  });

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime parsedDate = DateTime.now();
    final rawDate = data['createdAt'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return GoalModel(
      id: doc.id,
      title: data['title'] ?? '',
      targetJob: data['targetJob'] ?? '',
      targetMonth: data['targetMonth'],
      targetYear: data['targetYear'],
      isCompleted: data['isCompleted'] ?? false,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'targetJob': targetJob,
      'targetMonth': targetMonth,
      'targetYear': targetYear,
      'isCompleted': isCompleted,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
