import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_storage_constants.dart';
import 'package:notes/services/cloud/cloud_storage_exceptions.dart';

class firebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      notes.doc(documentId).delete();
    } catch (e) {
      throw couldnotDeleteNoteExcept();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
  }) async {
    try {
      notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw couldnotUpdateNotesExcept();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<CollectionReference<Map<String, dynamic>>> getNotes(
      {required String ownerUserId}) async {
    try {
      await notes
          .where(
            ownerUderIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)),
          );
    } catch (e) {
      throw couldnotGetAllNotesExcept();
    }
    return notes;
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUderIdFieldName: ownerUserId,
      textFieldName: '',
    });
    final fetchednote = await document.get();
    return CloudNote(
      fetchednote.id,
      ownerUserId,
      '',
    );
  }

  static final firebaseCloudStorage _shared =
      firebaseCloudStorage._sharedInstance();
  firebaseCloudStorage._sharedInstance();
  factory firebaseCloudStorage() => _shared;
}
