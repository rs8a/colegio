part of 'signin_bloc.dart';

enum SignInStatus {
  unknow,
  submitting,
  success,
  failure,
}

class SignInState extends Equatable {
  final SignInStatus status;
  final Object exception;

  const SignInState._({this.status = SignInStatus.unknow, this.exception = 1});

  const SignInState.unknow() : this._();

  const SignInState.submitting()
      : this._(
          status: SignInStatus.submitting,
        );

  const SignInState.success()
      : this._(
          status: SignInStatus.success,
        );

  const SignInState.failure(Object exception)
      : this._(
          status: SignInStatus.failure,
          exception: exception,
        );

  // SignInState copyWith({SignInStatus? status, dynamic exception}) {
  //   print('class: ${status.toString()}');
  //   return new SignInState(
  //     status: status,
  //     exception: exception ?? null,
  //   );
  // }

  @override
  List<Object> get props => [status, exception];
}
