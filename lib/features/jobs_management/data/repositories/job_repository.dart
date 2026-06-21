import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myjobs/features/jobs_management/data/models/job_application_model.dart';

class JobRepository {
  final CollectionReference _jobsCollection = FirebaseFirestore.instance.collection('jobs');

  Future<void> addJob(JobApplication job) async {
    await _jobsCollection.add(job.toFirestore());
  }

  Stream<List<JobApplication>> getJobsStream() {
    return _jobsCollection.orderBy('appliedDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => JobApplication.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    await _jobsCollection.doc(jobId).update({'status': newStatus});
  }
}
