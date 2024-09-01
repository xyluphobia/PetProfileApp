
import 'package:flutter/material.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({super.key, required this.location, required this.press, required this.indexPassed, required this.listLength});

  final String location;
  final VoidCallback press;
  final int indexPassed;
  final int listLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (indexPassed == 0) Divider(
          height: 2,
          thickness: 1,
          indent: 20,
          endIndent: 20,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        ListTile(
          onTap: press,
          horizontalTitleGap: 0,
          leading: const Icon(Icons.location_city),
          title: Text(
            location,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}