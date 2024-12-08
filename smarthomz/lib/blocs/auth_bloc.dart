import 'package:SmartHomz/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart'; // Your custom User model
import '../repos/authentication_repo.dart';
import '../screens/login.dart';

// Auth Events
abstract class AuthEvent {}

class SignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context;

  SignInWithEmail(this.email, this.password, this.context);
}

class SignUpWithEmail extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context;

  SignUpWithEmail(this.email, this.password, this.context);
}

class SignOut extends AuthEvent {}

// Auth States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

// AuthBloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<SignInWithEmail>(_signInWithEmail);
    on<SignUpWithEmail>(_signUpWithEmail);
    on<SignOut>(_signOut);
  }

  void _signInWithEmail(SignInWithEmail event, Emitter<AuthState> emit) async {
    try {
      User? user = await _authRepository.signInWithEmail(event.email, event.password);
      if (user != null) {
        emit(Authenticated(user));
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('Logged in Successfully!')),
        );
        Navigator.pushReplacement(
          event.context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        emit(AuthError('Authentication failed: Invalid email or password.'));

      }
    } catch (e) {
      emit(AuthError('Authentication error: $e'));
    }
  }

  void _signUpWithEmail(SignUpWithEmail event, Emitter<AuthState> emit) async {
    try {
      User? user = await _authRepository.signUpWithEmail(event.email, event.password);
      if (user != null) {
        emit(Authenticated(user));
        // Show success notification and navigate to login screen
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushReplacement(
          event.context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _signOut(SignOut event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
