import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myjobs/features/job_platforms/data/models/platform_model.dart';

class PlatformRepository {
  final CollectionReference _platformsCollection = FirebaseFirestore.instance.collection('platforms');

  Future<void> addPlatform(PlatformModel platform) async {
    await _platformsCollection.add(platform.toFirestore());
  }

  Stream<List<PlatformModel>> getPlatformsStream() {
    return _platformsCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => PlatformModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> deletePlatform(String id) async {
    await _platformsCollection.doc(id).delete();
  }
}
