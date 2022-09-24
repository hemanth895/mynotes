import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('should not be intialised to begin with', () {
      expect(provider.isInitialised, false);
    });
    test('coannot logout if not initialised', () {
      expect(
        provider.logout(),
        throwsA(const TypeMatcher<NotInitialisedException>()),
      );
    });
    test('should be able to initialised', () async {
      await provider.initialize();
      expect(provider.isInitialised, false);
    });
    test('user should be null after initialisation', () {
      expect(provider.currentUser, null);
    });

    test(
      'should be able to init in 2 secs',
      () async {
        provider.isInitialised;
        expect(provider.isInitialised, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('create user should delegate to login', () async {
      final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'foobar',
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundException>()),
      );
      final badpassworduser = provider.createUser(
        email: 'fii@bar.com',
        password: 'foobar',
      );
      expect(
        badpassworduser,
        throwsA(const TypeMatcher<WrogPasswordAuthException>()),
      );
      final user = provider.createUser(
        email: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      //expect(user?.isEmailVerified, false);
    });
    test('logged user should be able to verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('should be able logout and login', () async {
      await provider.login(email: 'user', password: 'user');
      await provider.logout();
    });
    final user = provider.currentUser;
    expect(user, isNotNull);
  });
}

class NotInitialisedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  final _isInitialised = false;
  AuthUser? _user;

  bool get isInitialised => _isInitialised;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialised) throw NotInitialisedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(
      email: email,
      password: password,
    );
  }

  @override
  
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!isInitialised) throw NotInitialisedException();
    if (email == 'foo@bar.com') throw UserNotFoundException();
    if (password == 'foobar') throw WrogPasswordAuthException();
    const user = AuthUser(
      isEmailVerified: false,
      email: 'foo@bar.com',
      id = 'my_id',
    );
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialised) throw NotInitialisedException();
    if (_user == null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialised) throw NotInitialisedException();
    final user = _user;
    if (user == null) throw UserNotFoundException();
    const newuser = AuthUser(
      id = 'my_id',
      isEmailVerified: true,
      email: 'foo@bar.com',
    );
    _user = newuser;
    
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    
    throw UnimplementedError();
  }
}
