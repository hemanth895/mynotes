import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:notes/services/auth/Bloc/Auth_Events.dart';
import 'package:notes/services/auth/Bloc/authBloc.dart';
import 'package:notes/services/auth/Bloc/auth_state.dart';

import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';


import '../utilities/dialog/errorDialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  // CloseDialog? _closeDialog;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          // final closeDialog = _closeDialog;
          // if (state.isLoading && closeDialog != null) {
          //   closeDialog();
          //   _closeDialog = null;
          // } else if (state.isLoading && closeDialog == null) {
          //   _closeDialog = showLoadingDialog(
          //     context: context,
          //     text: 'loading..',
          //   );
          // }
          if (state.exception is UserNotFoundException) {
            await showErrorDialog(
                context, 'cannot find a user with entered credentials');
          } else if (state.exception is WrogPasswordAuthException) {
            await showErrorDialog(context, 'wrong credentials..');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error..');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Login")),
        body: FutureBuilder(
          future: AuthService.firebase().initialize(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('please login to your account'),
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
                        decoration: const InputDecoration(
                            hintText: "enter ur password"),
                      ),
                      TextButton(
                          onPressed: () async {
                            await AuthService.firebase().initialize();
                            final email = _email.text;
                            final password = _password.text;
                            context.read<AuthBloc>().add(
                                  AuthEventLoggIn(
                                    email,
                                    password,
                                  ),
                                );
                            // try {
                            //   context.read<AuthBloc>().add(
                            //         AuthEventLoggIn(
                            //           email,
                            //           password,
                            //         ),
                            //       );

                            //   // await AuthService.firebase()
                            //   //     .login(email: email, password: password);

                            //   // final user = AuthService.firebase().currentUser;
                            //   // if (user?.isEmailVerified ?? false) {
                            //   //   Navigator.of(context).pushNamedAndRemoveUntil(
                            //   //     notesRoute,
                            //   //     (route) => false,
                            //   //   );
                            //   // } else {
                            //   //   Navigator.of(context).pushNamedAndRemoveUntil(
                            //   //     verify,
                            //   //     (route) => false,
                            //   //   );
                            //   // }
                            // } on UserNotFoundException catch (_) {
                            //   await showErrorDialog(
                            //     context,
                            //     'user not found',
                            //   );
                            // } on WrogPasswordAuthException catch (_) {
                            //   await showErrorDialog(
                            //     context,
                            //     'wrong credentials',
                            //   );
                            // } on GenericAuthException catch (_) {
                            //   await showErrorDialog(
                            //     context,
                            //     'Authentication error',
                            //   );
                            //}

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
                          // Navigator.of(context).pushNamedAndRemoveUntil(
                          //   register,
                          //   (route) => false,
                          // );
                          context
                              .read<AuthBloc>()
                              .add(const AuthEventShouldRegister());
                        },
                        child: const Text('not registered yet?register here!'),
                      ),

                      TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(AuthEventForgotpassword());
                        },
                        child: const Text('forgot password!'),
                      ),
                    ],
                  ),
                );
              default:
                return const Text('logging in ....wait for  a while ');
            }
          },
        ),
      ),
    );
  }
}
