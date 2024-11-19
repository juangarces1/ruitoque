import 'package:flutter/material.dart';
import 'package:ruitoque/constans.dart';


class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
 final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final Color? shadowColor;
  final Color? foreColor;
  final PreferredSizeWidget? bottom;

  const MyCustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.elevation,
    required this.automaticallyImplyLeading,
    this.shadowColor,
    this.foreColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondoHome.webp'), // Aquí va la imagen que quieres
                fit: BoxFit.cover, // Ajusta la imagen para que cubra todo el AppBar
              ),
            ),
          ),
      title: Text(title, style: kTextStyleNegroRobotoSize20),
      actions: actions,
      leading: automaticallyImplyLeading && Navigator.canPop(context)
          ? Padding(
              padding: const EdgeInsets.all(8.0), // Adjust padding as needed
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  backgroundColor: kPcontrastAzulColor,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white, // Change this color as needed
                  size: 24.0, // Adjust size as needed
                ),
              ),
            )
          : null,
      backgroundColor: backgroundColor,
      elevation: elevation ?? 4.0,
      shadowColor: shadowColor,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}