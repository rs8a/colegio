import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../blocs/authentication/repository/auth_repository.dart';

class RecoveryPasswordDialog {
  final BuildContext context;
  final bool useRootNavigator;
  final bool barrierDismissible;
  final Color? barrierColor;
  RecoveryPasswordDialog(
    this.context, {
    this.barrierDismissible = true,
    this.barrierColor = Colors.black54,
    this.useRootNavigator = true,
  });

  void showRecoveryPasswordDialog() {
    Navigator.of(context, rootNavigator: useRootNavigator).push(
      PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (_, Animation<double> animation,
                Animation<double> secondaryAnimation) =>
            FadeTransition(
          opacity: animation,
          child: RecoveryPasswordDialogPage(
            barrierDismissible: barrierDismissible,
            barrierColor: barrierColor,
          ),
        ),
      ),
    );
  }
}

class RecoveryPasswordDialogPage extends StatefulWidget {
  final bool barrierDismissible;
  final Color? barrierColor;

  const RecoveryPasswordDialogPage({
    Key? key,
    this.barrierDismissible = true,
    this.barrierColor = Colors.black54,
  }) : super(key: key);

  @override
  State<RecoveryPasswordDialogPage> createState() =>
      _RecoveryPasswordDialogPageState();
}

class _RecoveryPasswordDialogPageState extends State<RecoveryPasswordDialogPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  //TextEditingController(text: 'emal2504@gmail.com');
  late AnimationController _introOutroAnimationController;
  late AnimationController _barrierAnimationController;
  dynamic opacityIntroOutroAnimation;
  dynamic scaleIntroOutroAnimation;
  dynamic scaleBarrierAnimation;
  bool _sending = false;
  @override
  void initState() {
    _introOutroAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _barrierAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    scaleIntroOutroAnimation = Tween(
      begin: -100.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
          parent: _introOutroAnimationController, curve: Curves.easeInOut),
    );
    opacityIntroOutroAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
          parent: _introOutroAnimationController, curve: Curves.easeInOut),
    );
    scaleBarrierAnimation = Tween(
      begin: 1.0,
      end: 1.015,
    ).animate(
      CurvedAnimation(
          parent: _barrierAnimationController, curve: Curves.easeIn),
    );
    _introOutroAnimationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.barrierDismissible) {
          _introOutroAnimationController.reverse().then((_) {
            Navigator.pop(context);
          });
        } else {
          _barrierAnimationController
              .forward()
              .then((value) => _barrierAnimationController.reverse());
        }
      },
      child: Scaffold(
        backgroundColor: widget.barrierColor,
        body: dialogWidget(),
      ),
    );
  }

  AnimatedBuilder dialogWidget() {
    return AnimatedBuilder(
        animation: _barrierAnimationController.view,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleBarrierAnimation.value,
            child: AnimatedBuilder(
                animation: _introOutroAnimationController.view,
                builder: (context, child) {
                  return Opacity(
                    opacity: opacityIntroOutroAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, scaleIntroOutroAnimation.value),
                      child: Center(
                        child: dialogDetail(),
                      ),
                    ),
                  );
                }),
          );
        });
  }

  Widget dialogDetail() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
            (MediaQuery.of(context).size.width > 490 &&
                    MediaQuery.of(context).size.height > 514)
                ? 20
                : 0),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          // FiestaThemes.hardShadow(context),
        ],
      ),
      width: MediaQuery.of(context).size.width > 500 ? 500 : null,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Olvidaste la contraseña?',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (!kReleaseMode)
                        Text(
                          widget.toStringShort(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.redAccent,
                          ),
                        ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).iconTheme.color!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: _sending
                          ? const SizedBox.shrink()
                          : InkWell(
                              child: const Icon(Icons.close),
                              onTap: () {
                                _introOutroAnimationController
                                    .reverse()
                                    .then((_) {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                    ),
                  )
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              height: 0,
            ),
            bodyContainer(),
            const Divider(
              thickness: 1,
              height: 0,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: _sending
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _sending = true;
                            });
                            await AuthRepository.instance
                                .sendPasswordResetWithEmail(
                                    email: _emailController.text)
                                .then((value) {
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                const snackBar =
                                    SnackBar(content: Text('Correo enviado'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }).then((value) {
                                Navigator.pop(context);
                              });
                            }).catchError((e) {
                              // Future.delayed();
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                const snackBar = SnackBar(
                                    content: Text('Usuario no encontrado'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }).then((value) {
                                setState(() {
                                  _sending = false;
                                });
                              });
                            });
                            // _introOutroAnimationController.reverse().then((_) {
                            //   Navigator.pop(context);
                            // });
                          }
                        },
                  style: OutlinedButton.styleFrom().copyWith(
                    side: MaterialStateProperty.resolveWith((states) {
                      Color borderColor = Theme.of(context).focusColor;
                      return BorderSide(color: borderColor, width: 1);
                    }),
                  ),
                  child: const Text('Enviar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bodyContainer() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(_sending
                ? 'Enviando correo...'
                : 'Ingresa el correo electrónico asocioado con tu cuenta y te enviaremos un correo electrónico con insttrucciones para restablecer tu contraseña'),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _sending
                  ? const LinearProgressIndicator()
                  : userTextField(true),
            ),
          ],
        ),
      ),
    );
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
}
