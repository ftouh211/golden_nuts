import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSource({
    required this.firebaseAuth,
  });

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Login failed: User not found');
    }

    return user;
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}