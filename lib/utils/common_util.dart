import 'package:flutter/material.dart';

Future<void> notification(BuildContext context, String header, String body) {
  return showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      titlePadding: const EdgeInsets.only(left: 24, top: 24),
      title: Text(
        header, 
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(decoration: TextDecoration.underline),
      ),
      contentPadding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
      content: Text(
        body,
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

Future<void> confirmProceedNotification(BuildContext context, String header, String body, Function onProceed, Function onCancel, {String proceedButtonText = "Confirm", String cancelButtonText = "Cancel"}) {
  return showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.primary,
      titlePadding: const EdgeInsets.only(left: 24, top: 24),
      title: Text(
        header, 
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      contentPadding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
      content: Text(
        body,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
      buttonPadding: const EdgeInsets.all(0),
      actions: [
        TextButton(
          child: Text(
            cancelButtonText, 
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          onPressed: ()  {
            onCancel();
          },
        ),
        const SizedBox(width: 8.0),
        TextButton(
          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onSurface)),
          child: Text(
            proceedButtonText, 
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          onPressed: () {
            onProceed();
          },
        ),
      ],
    ),
  );
}

String? formatAddressToPostal(String? address) {
  if (address == null) return null;
  // Split the address by commas to break it into parts
  List<String> parts = address.split(', ');

  // Join the parts with newlines
  if (parts.length >= 3)
  {
    return '${parts[0]},\n${parts.sublist(1, parts.length - 1).join(", ")},\n${parts.last}';  
  }
  else {
    if (parts.length == 2) {
      return '${parts[0]},\n${parts[1]}\n';
    } else {
      return "$address\n\n";
    }
  }
}