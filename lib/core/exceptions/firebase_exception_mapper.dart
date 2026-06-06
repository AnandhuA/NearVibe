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

      if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const AppException(
            'Permission denied',
          );

        case 'not-found':
          return const AppException(
            'Data not found',
          );

        case 'unavailable':
          return const AppException(
            'Service unavailable',
          );

        default:
          return AppException(
            error.message ?? 'Firebase error',
          );
      }
    }

    return const AppException(
      'Something went wrong',
    );
  }
}