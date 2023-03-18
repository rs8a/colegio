import 'package:flutter/material.dart';

Future<dynamic> gestuNavigateTo(BuildContext context,
    {bool rootNavigator = false, required Widget child}) async {
  return Navigator.of(context, rootNavigator: rootNavigator).push(
    PageRouteBuilder(
      opaque: false,
      fullscreenDialog: true,
      pageBuilder: (_, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          FadeTransition(
        opacity: animation,
        child: child,
      ),
    ),
  );
}

Future<dynamic> gestuNavigateModalTo(
  BuildContext context, {
  required Widget child,
  bool rootNavigator = true,
}) {
  return Navigator.of(context, rootNavigator: rootNavigator).push(
    MaterialPageRoute<dynamic>(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return child;
      },
    ),
  );
}

Future<dynamic> gestuNavigatePushTo(
  BuildContext context, {
  required Widget child,
  bool rootNavigator = true,
}) {
  return Navigator.of(context, rootNavigator: rootNavigator).push(
    MaterialPageRoute<dynamic>(
      fullscreenDialog: false,
      builder: (BuildContext context) {
        return child;
      },
    ),
  );
}
