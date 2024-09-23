import 'package:flutter/material.dart';

// Modelo para los ítems del menú
class MenuItem {
  final String title;
  final Widget leading;
  final VoidCallback onTap;
  final Color textColor;

  MenuItem({
    required this.title,
    required this.leading,
    required this.onTap,
    this.textColor = const Color(0xffadb5bd),
  });
}
