import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../class/user.dart';
import '../repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User>? _userFirListener;
  StreamSubscription<User>? _userDataListener;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(InitialState()) {
    _userFirListener = authRepository.userFir
        .listen((user) => add(ChangedUserEvent(user, false)));

    on<ChangedUserEvent>((event, emit) async {
      // await Future.delayed(const Duration(seconds: 3));
      if (event.user != User.empty) {
        _userDataListener?.cancel();

        _userDataListener =
            _authRepository.userData(event.user).listen((user) async {
          if (state is AuthenticatedState) {
            if (user != (state as AuthenticatedState).user) {
              add(ChangedUserEvent(user, true));
            }
          }
        });

        emit(AuthenticatedState(
          event.user,
          event.userLoaded,
        ));
      } else {
        _userDataListener?.cancel();
        emit(UnauthenticatedState());
      }
    });

    on<SignedOutEvent>((event, emit) async {
      try {
        await _authRepository.signOut();
        emit(UnauthenticatedState());
        // debugPrint('===> Logged Out event');
      } catch (e) {
        AuthState lastState = state;
        emit(FailureState(e));
        await Future.delayed(const Duration(seconds: 5));
        emit(lastState);
      }
    });
  }

  @override
  Future<void> close() {
    _userDataListener?.cancel();
    _userFirListener?.cancel();
    return super.close();
  }
}
