import 'dart:async';

import 'package:flutter/material.dart';

class FlushMessageWidget extends StatefulWidget {
  final bool showMessage;
  final Widget? icon;
  final Widget message;
  final Widget? closeIcon;
  final VoidCallback? dismissAction;

  final Duration? duration;
  final bool? hideCloseButton;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showBorder;
  final Color? dismissActionColor;

  const FlushMessageWidget(
    this.showMessage, {
    Key? key,
    required this.message,
    this.icon,
    this.closeIcon,
    this.dismissAction,
    this.duration,
    this.hideCloseButton,
    this.backgroundColor,
    this.borderColor,
    this.showBorder = false,
    this.dismissActionColor,
  }) : super(key: key);

  @override
  State<FlushMessageWidget> createState() => _FlushMessageWidgetState();
}

class _FlushMessageWidgetState extends State<FlushMessageWidget>
    with SingleTickerProviderStateMixin {
  bool? _showMessage;
  Timer? t;
  late bool closeButton;
  @override
  void initState() {
    // print('object re');
    _showMessage = _showMessage ?? widget.showMessage;
    closeButton = (widget.duration == null && widget.hideCloseButton == null)
        ? true
        : widget.duration != null
            ? widget.hideCloseButton == null
                ? false
                : !widget.hideCloseButton!
            : !widget.hideCloseButton!;
    if (widget.duration != null) {
      if (_showMessage!) {
        t = Timer(widget.duration!, () {
          dismissAction();
        });
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      curve: Curves.bounceOut,
      duration: const Duration(milliseconds: 1000),
      // vsync: this,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showMessage!
            ? Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: widget.backgroundColor ??
                      Theme.of(context).colorScheme.error,
                  border: widget.showBorder
                      ? Border.all(
                          color: widget.borderColor ??
                              Theme.of(context).colorScheme.error,
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    widget.icon ?? const SizedBox.shrink(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: widget.message,
                      ),
                    ),
                    closeButton
                        ? IconButton(
                            onPressed: dismissAction,
                            icon: widget.closeIcon ??
                                Icon(
                                  Icons.close_rounded,
                                  color: widget.dismissActionColor,
                                ),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              )
            : const SizedBox(
                width: double.infinity,
              ),
      ),
    );
  }

  void dismissAction() {
    setState(() {
      _showMessage = false;
    });
    widget.dismissAction?.call();
  }
}
