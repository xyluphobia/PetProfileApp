import 'package:flutter/material.dart';

Future<void> basicError(BuildContext context, String errorBody) {
  return showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      titlePadding: const EdgeInsets.only(left: 24, top: 24),
      title: Text(
        "Error", 
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(decoration: TextDecoration.underline),
      ),
      contentPadding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
      content: Text(
        errorBody,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
      buttonPadding: const EdgeInsets.all(0),
      actions: [
        TextButton(
          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onSurface)),
          child: Text(
            "Ok", 
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}