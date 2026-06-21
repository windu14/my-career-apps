import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myjobs/features/goals/data/models/goal_model.dart';

class GoalRepository {
  final CollectionReference _goalsCollection = FirebaseFirestore.instance.collection('goals');

  Future<void> addGoal(GoalModel goal) async {
    await _goalsCollection.add(goal.toFirestore());
  }

  Stream<List<GoalModel>> getGoalsStream() {
    return _goalsCollection.orderBy('createdAt', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> toggleGoalCompletion(String id, bool currentStatus) async {
    await _goalsCollection.doc(id).update({'isCompleted': !currentStatus});
  }

  Future<void> deleteGoal(String id) async {
    await _goalsCollection.doc(id).delete();
  }
}
