import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../blocs/authentication/repository/auth_repository.dart';
import '../../../../../blocs/authentication/signin_bloc/signin_bloc.dart';
import '../widgets/flush_message_widget.dart';
import '../widgets/recovery_password_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInBloc(authRepository: AuthRepository.instance),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: constraints.copyWith(
                  minHeight: constraints.maxHeight,
                  maxHeight: double.infinity,
                ),
                child: const LoginFormWidget(),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({Key? key}) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();

  bool isLarge = true;
  bool obscureText = true;

  final TextEditingController _emailController = TextEditingController();
  // TextEditingController(text: 'emal2504@gmail.com');
  final TextEditingController _passwordController = TextEditingController();
  // TextEditingController(text: '123456');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double currentWidth = MediaQuery.of(context).size.width;

    isLarge = currentWidth >= 490;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isLarge ? 20 : 0),
          boxShadow: [
            BoxShadow(
              blurRadius: 30.0,
              offset: const Offset(0, 10),
              color: Theme.of(context).shadowColor.withOpacity(0.5),
            )
          ],
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        width: isLarge ? 450 : currentWidth,
        child: Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo_colegio.png',
                  height: 300,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  width: double.infinity,
                  child: Text(
                    'Inicio de sesión',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Theme.of(context).focusColor,
                    ),
                  ),
                ),
                Divider(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(0.3),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: isLarge ? 40 : 20,
                  ),
                  child: formItems(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget formItems() {
    final signInBloc = BlocProvider.of<SignInBloc>(context, listen: true);
    bool showItem = signInBloc.state.status == SignInStatus.submitting ||
        signInBloc.state.status == SignInStatus.success;

    return Column(children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: AnimatedSize(
          duration: const Duration(seconds: 1),
          curve: Curves.bounceOut,
          child: signInBloc.state.status == SignInStatus.failure
              ? errorMessage(signInBloc.state)
              : Container(),
        ),
      ),
      const SizedBox(height: 20),
      userTextField(!showItem),
      const SizedBox(height: 20),
      passwordTextField(!showItem),
      const SizedBox(height: 20),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: AnimatedSize(
          duration: const Duration(seconds: 1),
          curve: Curves.bounceOut,
          child: // loginButton(context),
              showItem
                  ? const CircularProgressIndicator()
                  : loginButton(context),
        ),
      ),
      const SizedBox(height: 20),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: AnimatedSize(
          duration: const Duration(seconds: 1),
          curve: Curves.bounceOut,
          child: forgotPasswordButton(context),
          // showItem ? Container() :
          // forgotPasswordButton(context),
        ),
      ),
    ]);
  }

  Widget userTextField(bool editing) {
    return TextFormField(
      key: Key('userTextField$editing'),
      textInputAction: TextInputAction.next,
      readOnly: !editing,
      controller: _emailController,
      autofillHints: editing ? [AutofillHints.username] : null,
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.solid,
          ),
        ),
        // filled: true,
        contentPadding: const EdgeInsets.all(16),
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        labelText: 'Correo electrónico',
        prefixIcon: const Icon(Icons.email),
      ),
      validator: (String? value) {
        if (value != null) {
          if (!EmailValidator.validate(value.trim())) {
            return 'El correo electrónico no es valido';
          } else if (value.isEmpty) {
            return 'Debe ingresar un correo electrónico';
          }
          return null;
        }
        return null;
      },
    );
  }

  Widget passwordTextField(bool editing) {
    // bool editing = true;
    return TextFormField(
      key: Key('passwordTextField$editing'),
      textInputAction: TextInputAction.go,
      onFieldSubmitted: (value) {
        loginAction();
      },
      readOnly: !editing,
      controller: _passwordController,
      autofillHints: editing ? [AutofillHints.password] : null,
      textCapitalization: TextCapitalization.none,
      keyboardType: obscureText ? TextInputType.visiblePassword : null,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            width: 0,
            style: BorderStyle.solid,
          ),
        ),
        // filled: true,
        contentPadding: const EdgeInsets.all(16),
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: InkWell(
          child: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onTap: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
        ),
      ),
      // decoration: InputDecoration(
      //   labelText: 'Contraseña',
      //   prefixIcon: Icon(Icons.lock),
      //   suffixIcon: InkWell(
      //     child: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
      //     onTap: () {
      //       setState(() {
      //         obscureText = !obscureText;
      //       });
      //     },
      //   ),
      // ),
      validator: (String? value) {
        if (value != null) {
          if (value.length < 6) {
            return 'La contraseña debe de tener al menos 6 caracteres';
          }
          return null;
        }
        return null;
      },
    );
  }

  Widget loginButton(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loginAction,
            child: const Text('Login'),
          ),
        );
      },
    );
  }

  Widget forgotPasswordButton(BuildContext context) {
    return Align(
      alignment: const Alignment(1, 0),
      child: TextButton(
        onPressed: () {
          RecoveryPasswordDialog(
            context,
            barrierDismissible: false,
          ).showRecoveryPasswordDialog();
        },
        child: const Text('¿Olvidaste la contraseña?'),
      ),
    );
  }

  Widget errorMessage(SignInState state) {
    return FlushMessageWidget(
      state.status == SignInStatus.failure,
      icon: Icon(
        Icons.block,
        color: Theme.of(context).colorScheme.error,
      ),
      message: Text(
        (state.exception is FirebaseAuthException)
            ? (state.exception as FirebaseAuthException).message.toString()
            : '',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.2),
      dismissActionColor: Theme.of(context).colorScheme.error,
      showBorder: true,
      borderColor: Theme.of(context).colorScheme.error.withOpacity(0.3),
    );
  }

  Future<void> loginAction() async {
    FocusScope.of(context).unfocus();
    await Future.delayed(
      const Duration(milliseconds: 100),
    );
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      BlocProvider.of<SignInBloc>(context).add(
        SignInWithCredentialsPressed(
          _emailController.text.trim(),
          _passwordController.text,
        ),
      );
    }
  }
}
