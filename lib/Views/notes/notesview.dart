//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/Views/notes/noteListView.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/crud/notesservice.dart';
//import 'dart:developer' as devtools show log;
import '../../constants/routes.dart';
import '../../enums/menuaction.dart';
import '../../main.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late final notesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = notesService();

    super.initState();
  }

  // @override
  // void dispose() {
  //   _notesService.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Notes'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(onSelected: ((value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);

                  if (shouldLogout) {
                    await AuthService.firebase().logout();

                    Navigator.of(context)
                        .restorablePushNamedAndRemoveUntil(login, (_) => false);
                  }
                  break;
              }
            }), itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log Out'),
                )
              ];
            })
          ],
        ),
        body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                    stream: _notesService.allNotes,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:

                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final allnotes = snapshot.data as List<dbnotes>;
                            return notesListView(
                                notes: allnotes,
                                onDeleteNote: (note) async {
                                  await _notesService.deletenotes(id: note.id);
                                });
                          } else {
                            return const CircularProgressIndicator();
                          }

                        default:
                          return const CircularProgressIndicator();
                      }
                    });
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}

// Future<bool> showLogOutDialog(BuildContext context) {
//   return showDialog<bool>(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('sign out'),
//         content:const Text('are u sure u want to sign out?'),
//         actions:[
//           TextButton(
//             onPressed: (){
//             Navigator.of(context).pop(false);
//           }, 
//           child: const Text('cancel'),
//           ),
//           TextButton(
//             onPressed: (){
//             Navigator.of(context).pop(true);
//           }, 
//           child: const Text('log out'),
//         ],
//       )
//     },
//   );
// }
