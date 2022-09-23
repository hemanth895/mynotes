//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:notes/services/auth/Bloc/Auth_Events.dart';
import 'package:notes/services/auth/Bloc/authBloc.dart';


class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('verify email!'),
      ),
      body: Column(
        children: [
          const Text('we\'have sent a verification mail to ur mail'),
          const Text(
              'if u haven\'t recived a verification mail,press the btn below'),
          TextButton(
              onPressed: () {
                // await AuthService.firebase().sendEmailVerification();
                context.read<AuthBloc>().add(
                      const AuthEventSendEmailVerification(),
                    );
                // final user = AuthService.firebase().currentUser;
                // await user?.sendEmailVerification();
              },
              child: const Text('send email verification')),
          TextButton(
            onPressed: () async {
              // await AuthService.firebase().logout();
              context.read<AuthBloc>().add(
                    const AuthEventLogout(),
                  );
              
              // Navigator.of(context).pushNamedAndRemoveUntil(
              //   register,
              //   (route) => false,
              // );
            },
            child: const Text('restart'),
          )
        ],
      ),
    );
  }
}
