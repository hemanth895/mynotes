import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/crud/notesservice.dart';

// ignore: camel_case_types
class newNotesView extends StatefulWidget {
  const newNotesView({super.key});

  @override
  State<newNotesView> createState() => _newNotesViewState();
}

// ignore: camel_case_types
class _newNotesViewState extends State<newNotesView> {
  dbnotes? _note;
  late final notesService _notesService;
  late final TextEditingController _textcontroller;

  @override
  void initState() {
    _notesService = notesService();
    _textcontroller = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textcontroller.text;
    await _notesService.updateNotes(
      note: note,
      text: text,
    );
  }

  void _setUpTextControlllerListener() {
    _textcontroller.removeListener(_textControllerListener);
    _textcontroller.addListener(_textControllerListener);
  }

  Future<dbnotes> createNewNote() async {
    final existingnote = _note;
    if (existingnote != null) {
      return existingnote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createnotes(owner: owner);
  }

  void _deleteNoteIfTextEmpty() {
    final note = _note;
    if (_textcontroller.text.isEmpty && note != null) {
      _notesService.deletenotes(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textcontroller.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNotes(
        note: note,
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
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as dbnotes;
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
