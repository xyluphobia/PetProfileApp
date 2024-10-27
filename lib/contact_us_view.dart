import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class ContactUsView extends StatefulWidget {
  const ContactUsView({super.key});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

final contactFormKey = GlobalKey<FormState>();

class _ContactUsViewState extends State<ContactUsView> {
  TextEditingController nameField = TextEditingController();
  TextEditingController emailField = TextEditingController();
  TextEditingController messageField = TextEditingController();

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
            Container(
              margin: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PhysicalModel(
                    color: Colors.transparent,
                    elevation: 1,
                    shape: BoxShape.circle,
                    child: CircleAvatar(
                      radius: 87,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: CircleAvatar(
                        radius: 80,
                        backgroundColor: Theme.of(context).colorScheme.onSurface,
                        backgroundImage: const Image(image: AssetImage('assets/images/matthewAboutPicture.jpg')).image,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                      
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Text(
                          "Buy NO Ads",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                      
                        }, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                        ),
                        child: Text(
                          "Dono Placeholder",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: contactFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameField,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Please enter your name.";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailField,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Please enter a valid email.";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: messageField,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Please enter your question or suggestion!";
                          }
                          return null;
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (contactFormKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Sent!"
                                ),
                              ),
                            );
                          }
                        }, 
                        style: ElevatedButton.styleFrom(
                          elevation: 1,
                          backgroundColor: Theme.of(context).colorScheme.onSurface,
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))
                        ),
                        child: Text(
                          "Send",
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Card(),
          ],
        ),
      ),
    );
  }
}