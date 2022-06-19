//import 'dart:html';

//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/Views/loginView.dart';
import 'package:notes/Views/registerview.dart';
import 'package:notes/Views/verifyemailview.dart';
import 'dart:developer' as devtools show log;
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:notes/Views/loginView.dart';
//import 'firebase_options/'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: LoginView(),
    routes: {
      //key value pairs strings->functions
      '/Login/': (context) => const LoginView(),
      '/Register/': (context) => const RegisterView(),
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
              // final emailVerified = user?.emailVerified ?? false;
              // if (emailVerified) {
              //   print('verified user');
              // } else {
              //   return const LoginView();
              // }
              // return const Text('done');
              return const LoginView();
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}

enum MenuAction { logout }

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
        title: const Text('main ui'),
        actions: [
          PopupMenuButton(onSelected: ((value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                devtools.log(shouldLogout.toString());
                if (shouldLogout) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).restorablePushNamedAndRemoveUntil(
                      '/Login/', (_) => false);
                }
                break;
            }
          }), itemBuilder: ((context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Log Out'),
              )
            ];
          }))
        ],
      ),
      body: const Text('hello world'),
    );
  }
}

//tap on
//upon pressing on popupmenuitem simulates onselect event
//showDialog and AlertDialog
//CTA call to action

//write a logout func to display dialog
Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('sign out'),
            content: const Text('are u syre u want to signout?'),
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
