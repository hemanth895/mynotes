import 'package:flutter/material.dart';

class newNotesView extends StatefulWidget {
  const newNotesView({super.key});

  @override
  State<newNotesView> createState() => _newNotesViewState();
}

class _newNotesViewState extends State<newNotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('new Note'),
      ),
      body: const Text('write your new note here....'),
    );
  }
}
