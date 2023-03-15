part of 'signin_bloc.dart';

abstract class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => [];
}

class Submitted extends SignInEvent {
  final String email;
  final String password;

  const Submitted(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignInWithGooglePressed extends SignInEvent {}

class SignInWithCredentialsPressed extends SignInEvent {
  final String email;
  final String password;

  const SignInWithCredentialsPressed(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}
