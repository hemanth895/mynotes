import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified);

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}


//authproviders
//create the class and add all the providers so that we can use them later





// class MyAuthUser extends AuthUser {
//   const MyAuthUser(bool isEmailVerified) : super(isEmailVerified);
// }
