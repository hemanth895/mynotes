import 'package:flutter/material.dart';
import 'package:notes/services/crud/notesservice.dart';

import '../../utilities/dialog/showDeleteDialog.dart';

typedef deleteNoteCallback = void Function(dbnotes note);

class notesListView extends StatelessWidget {
  final List<dbnotes> notes;
  final deleteNoteCallback onDeleteNote;
  const notesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
