import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:pet_profile_app/utils/common_util.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsView extends StatefulWidget {
  const ContactUsView({super.key});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

final contactFormKey = GlobalKey<FormState>();

class _ContactUsViewState extends State<ContactUsView> {
  TextEditingController nameField = TextEditingController();
  TextEditingController subjectField = TextEditingController();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 12,
            right: 16,
            left: 16,
          ),
          child: Column(
            children: [
              Container( // Image / Donations / Remove Ads
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
                            confirmProceedNotification(
                              context, 
                              "Remove Ads", 
                              "body", 
                              () {
                                print("went ahead");
                              }, 
                              () {
                                Navigator.of(context).pop();
                              },
                              proceedButtonText: "Remove Ads"
                            );
                          }, 
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            overlayColor: WidgetStateProperty.resolveWith<Color?>(
                              (states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.black.withOpacity(0.1); // Dark splash effect
                                }
                                return null; // Default overlay color
                              },
                            ),
                          ),
                          child: Text(
                            "Remove Ads",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            confirmProceedNotification(
                              context, 
                              "Support Pet Tether", 
                              "Love Pet Tether? Support its development and earn a supporter badge! Donations aren't expected but are always appreciated—every bit helps keep us growing!", 
                              () {
                                print("confirmed");
                              }, 
                              () {
                                Navigator.of(context).pop();
                              },
                              proceedButtonText: "Support",
                            );
                          }, 
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.primary,
                            ),
                            overlayColor: WidgetStateProperty.resolveWith<Color?>(
                              (states) {
                                if (states.contains(WidgetState.pressed)) {
                                  return Colors.black.withOpacity(0.1); // Dark splash effect
                                }
                                return null; // Default overlay color
                              },
                            ),
                          ),
                          child: Text(
                            "Support Pet Tether",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),
              Card( // About me
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 10.0),
                  child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text(
                        "About Me",
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(decoration: TextDecoration.underline),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        "Hi, I'm Matthew! I'm the sole developer of Pet Tether.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        "I built Pet Tether to make sharing all the essential information someone may need about your pet quick and easy.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              Card( // Contact form
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                  child: Form(
                    key: contactFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Get in Touch",
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(decoration: TextDecoration.underline),
                        ),
                        const SizedBox(height: 6.0),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Have a question, suggestion or just want to talk about your experience with Pet Tether? Send me an email at ",
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
                                      'subject': 'Pet Tether Contact',
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
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: nameField,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: "Name*",
                            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            errorStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red[900] as Color),
                            filled: true,
                            fillColor: const Color.fromARGB(8, 0, 0, 0),
                            border: inputBorder,
                            focusedBorder: inputBorder,
                            errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: Colors.red[900] as Color)),
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
                          controller: subjectField,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: "Subject",
                            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            errorStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red[900] as Color),
                            filled: true,
                            fillColor: const Color.fromARGB(8, 0, 0, 0),
                            border: inputBorder,
                            focusedBorder: inputBorder,
                            errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: Colors.red[900] as Color)),
                            enabledBorder: inputBorder,
                            disabledBorder: inputBorder,
                            focusedErrorBorder: inputBorder, 
                          ),
                        ),
                        const SizedBox(height: 8.0), // Space between form elements
                        TextFormField(
                          controller: messageField,
                          minLines: 4,
                          maxLines: 4,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: "Message*",
                            alignLabelWithHint: true,
                            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                            errorStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red[900] as Color),
                            filled: true,
                            fillColor: const Color.fromARGB(8, 0, 0, 0),
                            border: inputBorder,
                            focusedBorder: inputBorder,
                            errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: Colors.red[900] as Color)),
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
                            onPressed: () async {
                              if (contactFormKey.currentState!.validate()) {
                                // send email.
                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: 'contact@pettether.com',
                                  query: encodeQueryParameters(<String, String>{
                                    'subject': '${subjectField.text} ~ ${nameField.text}',
                                    'body': messageField.text,
                                  })
                                );

                                String snackBarText = "Failed to launch E-mail.";
                                if (await canLaunchUrl(emailLaunchUri)) {
                                  launchUrl(emailLaunchUri);
                                  snackBarText = "Launching!";
                                }
                                  
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      snackBarText,
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
            ],
          ),
        ),
      ),
    );
  }
}