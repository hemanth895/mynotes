import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final bool isEmailVerified;
  final String email;

  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email!,
        isEmailVerified: user.emailVerified,
        id: user.uid,
      );
}


//authproviders
//create the class and add all the providers so that we can use them later





// class MyAuthUser extends AuthUser {
//   const MyAuthUser(bool isEmailVerified) : super(isEmailVerified);
// }


