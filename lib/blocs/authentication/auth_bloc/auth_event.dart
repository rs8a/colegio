part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthEventInitial extends AuthEvent {}

class SignedOutEvent extends AuthEvent {}

class ChangedUserEvent extends AuthEvent {
  final User user;

  final bool userLoaded;
  const ChangedUserEvent(this.user, this.userLoaded);

  @override
  List<Object?> get props => [user, userLoaded];
}
