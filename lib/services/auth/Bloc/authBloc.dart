import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/Bloc/Auth_Events.dart';
import 'package:notes/services/auth/Bloc/auth_state.dart';
import 'package:notes/services/auth/auth_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialise>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    on<AuthEventLoggIn>((event, emit) async {
      emit(const AuthStateLoading());
      final email = event.Email;
      final password = event.passwored;

      try {
        final user = await provider.login(
          email: email,
          password: password,
        );
        emit(AuthStateLoggedIn(user));
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });

    on<AuthEventLogout>((event, emit) async {
      try {
        emit(const AuthStateLoading());
        await provider.logout();
        emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(AuthStateLoggedOutFailure(e));
      }
    });
  }
}
