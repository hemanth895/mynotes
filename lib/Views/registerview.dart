//import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/showErrorDialog.dart';

//import '../firebase_options.dart';
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
          future: AuthService.firebase().initialize(),
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
                            await AuthService.firebase().createUser(
                              email: email,
                              password: password,
                            );

                            //final user = AuthService.firebase().currentUser;
                            AuthService.firebase().sendEmailVerification();
                            Navigator.of(context).pushNamed(verify);

                            //devtools.log(usercredential.toString());
                          } on WeakPasswordAuthExceptions catch (_) {
                            showErrorDialog(
                              context,
                              'weak password',
                            );
                          } on EmailAlreadyInUseException catch (_) {
                            await showErrorDialog(
                              context,
                              'email already in use',
                            );
                          } on InvalidEmailAuthException catch (_) {
                            await showErrorDialog(
                              context,
                              'invalid email',
                            );
                          } on GenericAuthException catch (_) {
                            await showErrorDialog(
                              context,
                              'failed to register',
                            );
                          }
                        },
                          
                        //   on FirebaseAuthException catch (e) {
                        //     if (e.code == 'weak password') {
                        //       showErrorDialog(
                        //         context,
                        //         'weak password',
                        //       );
                        //     } else if (e.code == 'email-already-in-use') {
                        //       await showErrorDialog(
                        //         context,
                        //         'email already in use',
                        //       );
                        //     } else if (e.code == 'invalid ') {
                        //       await showErrorDialog(
                        //         context,
                        //         'invalid email',
                        //       );
                        //     } else {
                        //       await showErrorDialog(
                        //         context,
                        //         'Error:${e.code}',
                        //       );
                        //     }
                        //   } catch (e) {
                        //     await showErrorDialog(
                        //       context,
                        //       e.toString(),
                        //     );
                        //   }
                        // },
                        child: const Text("Register")),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil(login, (route) => false);
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
