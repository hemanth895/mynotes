//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;
import '../constants/routes.dart';
import '../enums/menuaction.dart';
import '../main.dart';

class notes extends StatefulWidget {
  const notes({super.key});

  @override
  State<notes> createState() => _notesState();
}

class _notesState extends State<notes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAIN UI'),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: ((value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                devtools.log(shouldLogout.toString());
                if (shouldLogout) {
                  await AuthService.firebase().logout();
                  // ignore: use_build_context_synchronously
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
      body: const Text('hello world'),
    );
  }
}
