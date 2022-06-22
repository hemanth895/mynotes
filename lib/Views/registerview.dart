import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text("Register")),
      body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: ((context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Column(
                  children: [
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          hintText: "enter ur email here"),
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
                          final email = _email.text;
                          final password = _password.text;
                          devtools.log(email);
                          try {
                            final usercredential = await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: email, password: password);
                            print(usercredential);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak password') {
                              devtools.log('weak-password');
                            } else if (e.code == 'email already in use') {
                              devtools.log('email already in use');
                            } else if (e.code == 'invalid ') {
                              devtools.log('invalid email');
                            }
                          }
                        },
                        child: const Text("Register")),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/Login/', (route) => false);
                        },
                        child: const Text('already registered ?login here!'))
                  ],
                );
              default:
                return const Text('loading....');
            }
          })),
    );
  }
}
