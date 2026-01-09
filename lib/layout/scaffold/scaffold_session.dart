import 'package:flutter/material.dart';

class ScaffoldSession extends StatefulWidget {
  const ScaffoldSession({
    super.key,
    required this.controller,
    this.maxWidth = 300.0,
    required this.body,
    required this.title,
    this.backgroundColor,
    this.bodyColor,
    required this.borderRadius,
  });

  final AnimationController controller;
  final double maxWidth;
  final Widget body;
  final String title;
  final Color? backgroundColor;
  final Color? bodyColor;
  final double borderRadius;

  @override
  State<ScaffoldSession> createState() => _ScaffoldSessionState();
}

class _ScaffoldSessionState extends State<ScaffoldSession> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        double xOffSet = widget.controller.value * widget.maxWidth;
        return Transform(
          transform: Matrix4.identity()..translate(xOffSet, 0, 0),
          alignment: Alignment.centerLeft,
          child: child,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
          title: Text(
            widget.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              if (widget.controller.isDismissed) {
                widget.controller.forward();
              } else {
                widget.controller.reverse();
              }
            },
          ),
        ),
        body: Container(
          color:
              widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
          width: double.infinity,
          height: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Container(
              color: widget.bodyColor ?? Theme.of(context).colorScheme.surface,
              width: double.infinity,
              height: double.infinity,
              child: widget.body,
            ),
          ),
        ),
      ),
    );
  }
}
