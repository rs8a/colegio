part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class InitialState extends AuthState {}

class AuthenticatedState extends AuthState {
  final User user;
  final bool userLoaded;

  const AuthenticatedState(this.user, this.userLoaded);

  @override
  List<Object> get props => [user, userLoaded];
}

class UnauthenticatedState extends AuthState {}

class FailureState extends AuthState {
  final dynamic exception;

  const FailureState(this.exception);

  @override
  List<Object> get props => [exception];
}
