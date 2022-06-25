import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
//import 'dart:developer' as devtools show log;

import 'package:notes/firebase_options.dart';

import '../utilities/showErrorDialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration:
                        const InputDecoration(hintText: "enter ur email here"),
                  ),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration:
                        const InputDecoration(hintText: "enter ur password"),
                  ),
                  TextButton(
                      onPressed: () async {
                        await Firebase.initializeApp(
                            options: DefaultFirebaseOptions.currentPlatform);

                        final email = _email.text;
                        final password = _password.text;

                        try {
                          final usercredential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          final user = FirebaseAuth.instance.currentUser;
                          if (user?.emailVerified ?? false) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              notesRoute,
                              (route) => false,
                            );
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              verify,
                              (route) => false,
                            );
                          }
                          
                        } on FirebaseAuthException catch (e) {
                          //runtimetype
                          if (e.code == 'user-not-found') {
                            // devtools.log('user not found');
                            await showErrorDialog(
                              context,
                              'user not found',
                            );
                          } else if (e.code == 'wrong-password') {
                            await showErrorDialog(
                              context,
                              'wrong credentials',
                            );
                          } else {
                            await showErrorDialog(
                              context,
                              'Error:${e.code}',
                            );
                          }
                        } catch (e) {
                          await showErrorDialog(
                            context,
                            e.toString(),
                          );
                        }

                        //  FirebaseAuth.instance.signInWithEmailAndPassword(
                        // email: email, password: password);
                        // final usercredential = await FirebaseAuth.instance
                        //     .signInWithEmailAndPassword(
                        //         email: email, password: password);
                        // print(usercredential);
                      },
                      child: const Text("Login")),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        register,
                        (route) => false,
                      );
                    },
                    child: const Text('not registered yet?register here!'),
                  ),
                ],
              );
            default:
              return const Text('logging in ....wait for  a while ');
          }
        },
      ),
    );
  }
}


