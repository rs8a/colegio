import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/auth_repository.dart';

part 'signin_event.dart';
part 'signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthRepository _authRepository;
  SignInBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SignInState.unknow()) {
    on<SignInWithCredentialsPressed>((event, emit) async {
      // debugPrint('emitter ====> $emit');
      // debugPrint('loginWithCredentialsPressed');
      emit(const SignInState.submitting());
      await Future.delayed(const Duration(seconds: 3));
      try {
        // debugPrint('email: ${event.email}, password: ${event.password}');
        await _authRepository.signInWithEmailAndPassword(
            email: event.email, password: event.password);
        emit(const SignInState.success());
      } catch (e) {
        emit(SignInState.failure(e));
      }
    });
  }

  // Stream<SignInState> mapEventToState(SignInEvent event) async* {
  //   // if (event is SignInWithGooglePressed) {
  //   //   yield* _mapWithGooglePressedToState();
  //   // }
  //   if (event is SignInWithCredentialsPressed) {
  //     // yield* _mapWithCredentialsPressedToState(event);

  //     yield const SignInState.submitting();

  //     await Future.delayed(const Duration(seconds: 3));
  //     try {
  //       await _authRepository.signInWithEmailAndPassword(
  //           email: event.email, password: event.password);
  //       yield const SignInState.success();
  //     } catch (e) {
  //       yield SignInState.failure(e);
  //     }
  //   }
  // }

  // Stream<SignInState> _mapWithGooglePressedToState() async* {
  //   yield state.copyWith(status: SignInStatus.submitting);
  //   try {
  //     await _authRepository.signInWithGoogle();
  //     yield state.copyWith(status: SignInStatus.success);
  //   } catch (e) {
  //     yield state.copyWith(status: SignInStatus.failure, exception: e);
  //   }
  // }

  // Stream<SignInState> _mapWithCredentialsPressedToState(
  //     SignInWithCredentialsPressed event) async* {
  //   yield state.copyWith(status: SignInStatus.submitting);
  //   try {
  //     await _authRepository.signInWithEmailAndPassword(
  //         email: event.email, password: event.password);
  //     yield state.copyWith(status: SignInStatus.success);
  //   } catch (e) {
  //     print(e);
  //     yield state.copyWith(status: SignInStatus.failure, exception: e);
  //   }
  // }
}
