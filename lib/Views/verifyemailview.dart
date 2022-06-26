//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_service.dart';

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
              onPressed: () async {
                await AuthService.firebase().sendEmailVerification();
                // final user = AuthService.firebase().currentUser;
                // await user?.sendEmailVerification();
              },
              child: const Text('send email verification')),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logout();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamedAndRemoveUntil(
                register,
                (route) => true,
              );
            },
            child: const Text('restart'),
          )
        ],
      ),
    );
  }
}
