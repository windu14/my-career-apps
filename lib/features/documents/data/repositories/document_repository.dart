import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myjobs/features/documents/data/models/document_model.dart';

class DocumentRepository {
  final CollectionReference _documentsCollection = FirebaseFirestore.instance.collection('documents');

  Future<void> addDocument(DocumentModel document) async {
    await _documentsCollection.add(document.toFirestore());
  }

  Stream<List<DocumentModel>> getDocumentsStream({int limit = 10}) {
    return _documentsCollection
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => DocumentModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> deleteDocument(String id) async {
    await _documentsCollection.doc(id).delete();
  }
}
