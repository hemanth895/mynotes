import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
//import 'package:notes/services/crud/notesservice.dart';
import 'package:notes/utilities/generics/get_arguments.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_storage_exceptions.dart';
import 'package:notes/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

import '../../utilities/dialog/cannot_share_empty.dart';

// ignore: camel_case_types
class createUpdateNoteView extends StatefulWidget {
  const createUpdateNoteView({super.key});

  @override
  State<createUpdateNoteView> createState() => _createUpdateNoteViewState();
}

// ignore: camel_case_types
class _createUpdateNoteViewState extends State<createUpdateNoteView> {
  CloudNote? _note;
  late final firebaseCloudStorage _notesService;
  late final TextEditingController _textcontroller;

  @override
  void initState() {
    _notesService = firebaseCloudStorage();
    _textcontroller = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textcontroller.text;
    await _notesService.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setUpTextControlllerListener() {
    _textcontroller.removeListener(_textControllerListener);
    _textcontroller.addListener(_textControllerListener);
  }

  Future<CloudNote> createorgetexistingNote(BuildContext context) async {
    final widgetNote = context.getArguement<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textcontroller.text = widgetNote.text;
      return widgetNote;
    }
    final existingnote = _note;
    if (existingnote != null) {
      return existingnote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;

    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextEmpty() {
    final note = _note;
    if (_textcontroller.text.isEmpty && note != null) {
      _notesService.deleteNote(
        documentId: note.documentId,
      );
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textcontroller.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextEmpty();
    _saveNoteIfTextNotEmpty();
    _textcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('new Note'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textcontroller.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: FutureBuilder(
        future: createorgetexistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // _note = snapshot.data as dbnotes;
              _setUpTextControlllerListener();
              return TextField(
                controller: _textcontroller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'start typing your note..',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
