//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/Views/notes/createUpdateNoteView.dart';
import 'package:notes/Views/notes/noteListView.dart';
import 'package:notes/services/auth/Bloc/Auth_Events.dart';
import 'package:notes/services/auth/Bloc/authBloc.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/cloud/firebase_cloud_storage.dart';
import 'package:notes/utilities/dialog/logoutDialog.dart';
//import 'package:notes/services/crud/notesservice.dart';
//import 'dart:developer' as devtools show log;
import '../../constants/routes.dart';
import '../../enums/menuaction.dart';
import '../../main.dart';
import '../../services/cloud/cloud_note.dart';
import 'package:notes/main.dart' show showLogOutDialog;

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late final firebaseCloudStorage _notesService;
  // String get userEmail => AuthService.firebase().currentUser!.email!;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = firebaseCloudStorage();

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
                Navigator.of(context).pushNamed(createUpdateNoteRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(onSelected: ((value) async {
              switch (value) {
                case MenuAction.logout:
                  
                  final shouldLogout =
                      await showLogOutDialog(context, 'log Out');

                  if (shouldLogout) {
                    context.read<AuthBloc>().add(AuthEventLogout());

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
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:

              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allnotes = snapshot.data as Iterable<CloudNote>;
                  return notesListView(
                    notes: allnotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    ontap: (note) {
                      Navigator.of(context).pushNamed(
                        createUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }

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
