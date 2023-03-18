import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/authentication/auth_bloc/auth_bloc.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: showPage(context, state),
          );
        },
      ),
    );
  }

  Widget showPage(BuildContext context, AuthState state) {
    if (state is AuthenticatedState) {
      return state.userLoaded
          ? const HomeScreen()
          : Center(
              child: ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(SignedOutEvent());
                  },
                  child: const Text('Cerrar sesion')));
    } else if (state is UnauthenticatedState) {
      return const LoginScreen();
    } else if (state is FailureState) {
      return const Center(child: Text('Error'));
    }
    return const Center(child: CircularProgressIndicator());
  }
}
