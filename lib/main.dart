//import 'dart:html';

// ignore_for_file: camel_case_types

//import 'package:firebase_core/firebase_core.dart';


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/Views/loginView.dart';
import 'package:notes/Views/registerview.dart';
import 'package:notes/Views/verifyemailview.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;

import 'Views/notesview.dart';
import 'firebase_options.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:notes/Views/loginView.dart';
//import 'firebase_options/'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const homepage(),
    routes: {
      //key value pairs strings->functions
      login: (context) => const LoginView(),
      register: (context) => const RegisterView(),
      notesRoute: (context) => const notes(),
      verify: ((context) => const VerifyEmailView()),
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
        future: AuthService.firebase().initialize(),
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
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
