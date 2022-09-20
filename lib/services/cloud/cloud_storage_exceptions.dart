import 'package:flutter/foundation.dart';

@immutable
class cloudStorageException implements Exception {
  const cloudStorageException();
}

class couldnotCreateNoteExcept implements cloudStorageException {}

class couldnotGetAllNotesExcept implements cloudStorageException {}

class couldnotUpdateNotesExcept implements cloudStorageException {}

class couldnotDeleteNoteExcept implements cloudStorageException {}
