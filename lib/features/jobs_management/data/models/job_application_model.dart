import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplication {
  final String id;
  final String title;
  final String company;
  final String appliedVia;
  final String? appliedViaDetail;
  final String? position1;
  final String? position2;
  final DateTime appliedDate;
  final String status;

  JobApplication({
    required this.id,
    required this.title,
    required this.company,
    required this.appliedVia,
    this.appliedViaDetail,
    this.position1,
    this.position2,
    required this.appliedDate,
    required this.status,
  });

  factory JobApplication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobApplication(
      id: doc.id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      appliedVia: data['appliedVia'] ?? '',
      appliedViaDetail: data['appliedViaDetail'],
      position1: data['position1'],
      position2: data['position2'],
      appliedDate: (data['appliedDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'baru apply',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'company': company,
      'appliedVia': appliedVia,
      'appliedViaDetail': appliedViaDetail,
      'position1': position1,
      'position2': position2,
      'appliedDate': Timestamp.fromDate(appliedDate),
      'status': status,
    };
  }
}
