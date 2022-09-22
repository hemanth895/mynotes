import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialise extends AuthEvent {
  const AuthEventInitialise();
}

class AuthEventLoggIn extends AuthEvent {
  final String Email;
  final String passwored;

  const AuthEventLoggIn(this.Email, this.passwored);
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}
