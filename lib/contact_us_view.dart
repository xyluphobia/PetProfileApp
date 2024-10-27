import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  OutlineInputBorder inputBorder = const OutlineInputBorder();

  @override
  void didChangeDependencies() {
    inputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.secondary,
      )
    );

    super.didChangeDependencies();
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
  }

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
            const SizedBox(height: 8.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                child: Form(
                  key: contactFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Send me an E-Mail!",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8.0),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Have a question, suggestion or just want to tell me about your experience with Pet Tether? Send me an email at ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextSpan(
                              text: "Contact@PetTether.com",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: 'contact@pettether.com',
                                  query: encodeQueryParameters(<String, String>{
                                    'subject': 'eeemail subby',
                                    'body': 'booody hi  :) 1.!',
                                  })
                                );
                                launchUrl(emailLaunchUri);
                              },
                            ),
                            TextSpan(
                              text: " or by filling out the form below.",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ]
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      TextFormField(
                        controller: nameField,
                        decoration: InputDecoration(
                          labelText: "Name",
                          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                          filled: true,
                          fillColor: const Color.fromARGB(8, 0, 0, 0),
                          border: inputBorder,
                          focusedBorder: inputBorder,
                          errorBorder: inputBorder,
                          enabledBorder: inputBorder,
                          disabledBorder: inputBorder,
                          focusedErrorBorder: inputBorder,
                        ),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Please enter your name.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0), // Space between form elements
                      TextFormField(
                        controller: emailField,
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                          filled: true,
                          fillColor: const Color.fromARGB(8, 0, 0, 0),
                          border: inputBorder,
                          focusedBorder: inputBorder,
                          errorBorder: inputBorder,
                          enabledBorder: inputBorder,
                          disabledBorder: inputBorder,
                          focusedErrorBorder: inputBorder, 
                        ),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Please enter a valid email.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0), // Space between form elements
                      TextFormField(
                        controller: messageField,
                        minLines: 4,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: "Message",
                          alignLabelWithHint: true,
                          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                          filled: true,
                          fillColor: const Color.fromARGB(8, 0, 0, 0),
                          border: inputBorder,
                          focusedBorder: inputBorder,
                          errorBorder: inputBorder,
                          enabledBorder: inputBorder,
                          disabledBorder: inputBorder,
                          focusedErrorBorder: inputBorder,
                        ),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "Please enter your question or suggestion!";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8.0), // Space between form elements
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                          ),
                          child: Text(
                            "Submit",
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                          ),
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