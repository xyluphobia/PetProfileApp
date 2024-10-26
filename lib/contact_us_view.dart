import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class ContactUsView extends StatefulWidget {
  const ContactUsView({super.key});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<ContactUsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: ImageIcon(const Image(image: Svg('assets/petTetherIcon.svg')).image, size: 28,),
        elevation: 1,
        leading: BackButton(
          onPressed: () async {
            Navigator.maybePop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 16,
          bottom: 8,
          right: 16,
          left: 16,
        ),
        child: Column(
          children: [
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    backgroundImage: const Image(image: AssetImage('assets/images/matthewAboutPicture.jpg')).image,
                  ),
                  Container(
                    height: 50,
                    width: 140,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            const Card(),
            const Card(),
          ],
        ),
      ),
    );
  }
}