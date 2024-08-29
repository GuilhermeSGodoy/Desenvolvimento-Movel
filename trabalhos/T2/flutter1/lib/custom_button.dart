import 'package:flutter/material.dart';

class CustomButtom extends StatelessWidget {

  final String text;
  final double padding;
  final iconData;
  final double spaceBetween;
  final void Function() callback;

  CustomButtom({ required this.text,
    required this.padding,
    required this.iconData,
    required this.spaceBetween,
    required this.callback
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: ElevatedButton(
        onPressed: callback,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData),
            SizedBox(width: spaceBetween,),
            Text(text),
          ],
        ),
      ),
    );
  }
}