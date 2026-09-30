
import 'dart:ui';

import 'package:flutter/material.dart';

class MyLoader extends StatefulWidget {
  final String text;
  final double opacity;

  // ignore: use_key_in_widget_constructors
  const MyLoader({this.text = '', required this.opacity});

  @override
  State<MyLoader> createState() => _MyLoaderState();
}

class _MyLoaderState extends State<MyLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Píldora compacta (logo girando + texto) para no tapar la pantalla.
    return Center(
      child: Opacity(
        opacity: widget.opacity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 18, 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: _controller,
                    child: Image.asset('assets/Loader.png', width: 32, height: 32, fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.text.isNotEmpty ? widget.text : 'Calculando...',
                    style: const TextStyle(
                      fontFamily: 'RobotoCondensed',
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
