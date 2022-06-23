//import 'dart:html';

// ignore_for_file: camel_case_types

//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/Views/loginView.dart';
import 'package:notes/Views/registerview.dart';
import 'package:notes/Views/verifyemailview.dart';
import 'dart:developer' as devtools show log;

import 'firebase_options.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:notes/Views/loginView.dart';
//import 'firebase_options/'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const LoginView(),
    routes: {
      //key value pairs strings->functions
      '/Login/': (context) => const LoginView(),
      '/Register/': (context) => const RegisterView(),
      '/notes/': (context) => const notes(),
    },
  ));
}

// ignore: camel_case_types
class homepage extends StatelessWidget {
  const homepage({Key? key}) : super(key: key);
//being manager for routing to different pages of the app
//and need to initialise firebase app

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                if (user.emailVerified) {
                  return const notes();
                }
              } else {
                return const VerifyEmailView();
              }
              // return const Text('done');
              
              return const LoginView();
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

enum MenuAction { logout }

// ignore: camel_case_types
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
                  await FirebaseAuth.instance.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).restorablePushNamedAndRemoveUntil(
                      '/Login/', (_) => false);
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

//tap on
//upon pressing on popupmenuitem simulates onselect event
//showDialog(stf class) and AlertDialog(stl class)

//


//CTA call to action
//future and functions

//write a logout func to display dialog
Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      //return optional boolean
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('sign out'),
            content: const Text('Are u sure u want to signout?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);

                },
                child: const Text('logout'),
              ),
            ]);
      }).then((value) => value ?? false);
}
