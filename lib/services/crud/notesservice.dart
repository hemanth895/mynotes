// ignore_for_file: await_only_futures

import 'dart:async';

import 'package:flutter/cupertino.dart';
//import 'package:notes/Views/notesview.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notes/services/crud/crud_exceptions.dart';

import 'package:path/path.dart' show join;

class notesService {
  Database? _db;
  List<dbnotes> _notes = [];
  static final notesService _shared = notesService._sharedInstance();
  notesService._sharedInstance();
  factory notesService() => _shared;
  final _notesStreamController = StreamController<List<dbnotes>>.broadcast();

  Stream<List<dbnotes>> get allNotes => _notesStreamController.stream;

  Future<void> _cachedNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<dbuser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

//private class/function
  // Future<void> _cacheNotes() async {
  //   final allnotes = await getAllNotes();
  //   _notes = allnotes.toList();
  //   _notesStreamController.add(_notes);
  // }

  Future<dbnotes> updateNotes(
      {required dbnotes note, required String text}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    await getnote(id: note.id);
    final updatescount = await db.update(
      notestbl,
      {textColumn: text},
    );

    if (updatescount == 0) {
      throw CouldNotUpdateNotes();
    } else {
      final updatedNote = await getnote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<dbnotes>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final notes = await db.query(notestbl);
    return notes.map((notesrow) => dbnotes.fromRow(notesrow));
  }

  Future<dbnotes> getnote({required int id}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final notes = await db.query(
      notestbl,
      where: 'id=?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      final note = dbnotes.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    // ignore: await_only_futures
    final db = await _getDatabaseOrThrow();
    final noOfdels = await db.delete(notestbl);
    _notes = [];
    _notesStreamController.add(_notes);
    return noOfdels;
  }

  Future<void> deletenotes({required int id}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final deletedcount = await db.delete(
      notestbl,
      where: 'id=?',
      whereArgs: [id],
    );
    if (deletedcount == 0) {
      throw CouldNotDeleteNotes();
    } else {
      final countBefore = _notes.length;
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<dbnotes> createnotes({required dbuser owner}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final dbuser = await getUser(email: owner.email);

    if (dbuser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';
    final notesid = await db.insert(notestbl, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithServerColumn: 1,
    });

    final note = dbnotes(
      id: notesid,
      userId: owner.id,
      text: text,
      isSyncedWithServer: true,
    );
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<dbuser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = await _getDatabaseOrThrow();
    final results = await db.query(
      usertbl,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return dbuser.fromRow(results.first);
    }
  }

  Future<dbuser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      usertbl,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExsists();
    }

    final userId = await db.insert(usertbl, {
      emailColumn: email.toLowerCase(),
    });

    return dbuser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedcount = await db.delete(
      usertbl,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedcount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {}
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docspath = await getApplicationDocumentsDirectory();
      final dbpath = join(docspath.path, dbname);
      final db = await openDatabase(dbpath);
      _db = db as Database?;

      await db.execute(createUserTable);

      await db.execute(createnotestable);
      await _cachedNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectory();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }
}

@immutable
class dbuser {
  final int id;
  final String email;
  const dbuser({
    required this.id,
    required this.email,
  });

  dbuser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'person,id=$id,email=$email';

  @override
  bool operator ==(covariant dbuser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class dbnotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithServer;

  dbnotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithServer,
  });
  dbnotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithServer =
            (map[isSyncedWithServerColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'note,id=$id,userId=$userId,isSyncedWithCloud=$isSyncedWithServer';

  @override
  bool operator ==(covariant dbnotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbname = 'notes.db';
const notestbl = 'notes';
const usertbl = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithServerColumn = 'is_synced_with_server';

const createUserTable = '''CREATE TABLE  IF NOT EXISTS "user" (
       	"id"	INTEGER NOT NULL,
       	"email"	TEXT NOT NULL UNIQUE,
       	PRIMARY KEY("id" AUTOINCREMENT)
         );''';

const createnotestable = '''CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	"is_synced_with_server"	INTEGER DEFAULT 0,
	FOREIGN KEY("user_id") REFERENCES "user"("id"),
	PRIMARY KEY("id" AUTOINCREMENT)
);''';
