import 'package:colegio/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/authentication/auth_bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AuthBloc _loginBloc;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1,
    ).animate(_animationController);
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    ));

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        loadingStuffNeeded();
      }
    });

    _animationController.forward();
    _loginBloc = BlocProvider.of<AuthBloc>(context);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/logo_colegio.png',
                  height: 300,
                ),
                const Spacer(),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future loadingStuffNeeded() async {
    // debugPrint('start loading and initializing all needed: ' +
    //     DateTime.now().toString());

    await Future.delayed(const Duration(milliseconds: 10));
    await Future.delayed(const Duration(milliseconds: 10));
    await Future.delayed(const Duration(milliseconds: 10));

    dismissMe();

    // debugPrint('end loading all: ' + DateTime.now().toString());
  }

  void dismissMe() {
    if (_loginBloc.state is AuthenticatedState ||
        _loginBloc.state is UnauthenticatedState) {
      _animationController.reverse().whenComplete(() {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (BuildContext context, Animation<double> animation,
                        Animation<double> secondaryAnimation) =>
                    const MainScreen(),
                transitionDuration: const Duration(milliseconds: 1500),
                transitionsBuilder: (context, animation, _, child) {
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                    child: child,
                  );
                }));
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        dismissMe();
      });
    }
  }
}
