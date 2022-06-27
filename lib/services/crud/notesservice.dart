import 'package:flutter/cupertino.dart';
import 'package:notes/Views/notesview.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notes/services/crud/crud_exceptions.dart';

import 'package:path/path.dart' show join;

class notesService {
  Database? _db;

  Future<dbnotes> updateNotes(
      {required dbnotes note, required String text}) async {
    final db = await _getDatabaseOrThrow();
    await getnote(id: note.id);
    final updatescount = await db.update(
      notestbl,
      {textColumn: text},
    );

    if (updatescount == 0) {
      throw CouldNotUpdateNotes();
    } else {
      return await getnote(id: note.id);
    }
  }

  Future<Iterable<dbnotes>> getAllNotes() async {
    final db = await _getDatabaseOrThrow();
    final notes = await db.query(notestbl);
    return notes.map((notesrow) => dbnotes.fromRow(notesrow));
  }

  Future<dbnotes> getnote({required int id}) async {
    final db = await _getDatabaseOrThrow();
    final notes = await db.query(
      notestbl,
      where: 'id=?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      return dbnotes.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = await _getDatabaseOrThrow();
    return db.delete(notestbl);
  }

  Future<void> deletenotes({required int id}) async {
    final db = await _getDatabaseOrThrow();
    final deletedcount = await db.delete(
      notestbl,
      where: 'id=?',
      whereArgs: [id],
    );
    if (deletedcount == 0) {
      throw CouldNotDeleteNotes();
    }
  }

  Future<dbnotes> createnotes({required dbuser owner}) async {
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
    return note;
  }

  Future<dbuser> getUser({required String email}) async {
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
  // TODO: implement hashCode
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
