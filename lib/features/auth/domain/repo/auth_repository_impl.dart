import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:golds_nuts/core/exeptions/failures.dart';
import 'package:golds_nuts/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:golds_nuts/features/auth/data/datasources/user_remote_data_source.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/auth/domain/repo/auth_repo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.userRemoteDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login using Firebase Authentication
      final firebaseUser = await authRemoteDataSource.login(
        email: email,
        password: password,
      );

      // 2. Get user data from Firestore
      final userModel = await userRemoteDataSource.getUserData(
        firebaseUser.uid,
      );

      // 3. Validate user profile
      if (userModel == null) {
        await authRemoteDataSource.logout();
        return Left(AuthFailure('User profile not found'));
      }

      // 4. Check account status
      if (!userModel.isActive) {
        await authRemoteDataSource.logout();
        return Left(AuthFailure('Your account is disabled'));
      }

      // 5. Validate user role
      if (userModel.role != 'manager' && userModel.role != 'worker') {
        await authRemoteDataSource.logout();
        return Left(AuthFailure('Invalid user role'));
      }

      // 6. Return successful result
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'A Firebase error occurred'));
    } catch (e) {
      return Left(ServerFailure('Something went wrong. Please try again.'));
    }
  }


  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await authRemoteDataSource.logout();

      return const Right(unit);
    } on FirebaseAuthException catch (e) {
      return Left(
        AuthFailure(e.message ?? 'Logout failed'),
      );
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'A Firebase error occurred'),
      );
    } catch (e) {
      return Left(
        ServerFailure('Something went wrong. Please try again.'),
      );
    }
  }


  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-not-found':
      case 'invalid-credential':
      case 'wrong-password':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      default:
        return 'Login failed. Please try again.';
    }
  }

}
