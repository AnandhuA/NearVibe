import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';

class FirebaseExceptionMapper {
  static AppException map(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return const AppException(
            'Email already in use',
          );

        case 'invalid-email':
          return const AppException(
            'Invalid email address',
          );

        case 'weak-password':
          return const AppException(
            'Password is too weak',
          );

        case 'user-not-found':
          return const AppException(
            'User not found',
          );

        case 'wrong-password':
          return const AppException(
            'Incorrect password',
          );

        default:
          return AppException(
            error.message ?? 'Authentication failed',
          );
      }
    }

    return const AppException(
      'Something went wrong',
    );
  }
}