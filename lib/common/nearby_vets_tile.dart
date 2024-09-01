import 'package:flutter/material.dart';

class NearbyVetsTile extends StatelessWidget {
  const NearbyVetsTile({super.key, required this.businessName, required this.formattedAddress, required this.phoneNumber, required this.isOpen});

  final String? businessName;
  final String? formattedAddress;
  final String? phoneNumber;
  final bool? isOpen;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.all(0),
            horizontalTitleGap: 0,
            titleAlignment: ListTileTitleAlignment.threeLine,
            isThreeLine: true,
            title: Text(
              formattedAddress != null ? formattedAddress! : "Address",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      phoneNumber != null ? phoneNumber! : "Phone Number",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      isOpen != null ? isOpen! ? "Open" : "Closed" : "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isOpen != null && isOpen! ? Colors.green : Colors.red),
                    ),
                  ],
                ),
                Text(
                  businessName != null ? businessName! : "Business Name",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.phone)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.directions)),
          ],
        )
      ],
    );
  }
}