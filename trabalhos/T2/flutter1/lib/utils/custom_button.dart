import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double padding;
  final IconData iconData;
  final double spaceBetween;
  final VoidCallback callback;

  const CustomButton({super.key,
    required this.text,
    required this.padding,
    required this.iconData,
    required this.spaceBetween,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: callback,
      icon: Icon(iconData),
      label: Text(text),
      style: ElevatedButton.styleFrom(padding: EdgeInsets.all(padding)),
    );
  }
}
