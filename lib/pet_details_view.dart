import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pet_profile_app/account_details.dart';
import 'package:pet_profile_app/utils/common_util.dart';
import 'package:pet_profile_app/utils/network_util.dart';
import 'package:provider/provider.dart';

import 'package:pet_profile_app/file_manager.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/pet_details.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class PetDetailsView extends StatefulWidget {
  final int petIndex;
  const PetDetailsView({super.key, required this.petIndex});

  @override
  State<PetDetailsView> createState() => _PetDetailsViewState();
}

class _PetDetailsViewState extends State<PetDetailsView> {
  bool newPet = false;
  bool assignPet = true;
  bool unsavedChanges = false;
  late Pet pet;
  late int petIndex = widget.petIndex;
  bool savedConfirmVisible = false;
  late Account account;

  Future<String?> selectImage(ImageSource imgSource, {bool petImage = true}) async {
    final returnedImage = await ImagePicker().pickImage(source: imgSource, imageQuality: 70);

    if (returnedImage == null) return null;

    String savedImagePath = await FileManager().saveImage(File(returnedImage.path));
    if (petImage)
    {
      if (pet.image != null) await FileManager().deleteFile(pet.image);
      setState(() {
        pet.image = savedImagePath;
      });
      return null;
    }
    return savedImagePath;
  }

  Future addOrEditPetData() async {
    PetDetails? petDetails = context.read<FileController>().petDetails;
    if (newPet) {
      petDetails?.data.add(pet);
      petIndex = (petDetails!.data.length - 1);
      setState(() {
        newPet = false;
      });
    }
    else {
      petDetails?.data[petIndex] = pet;
    }
    unsavedChanges = false;
    await context.read<FileController>().writePetDetails(petDetails!);
    setState(() {
      savedConfirmVisible = true;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        savedConfirmVisible = false;
      });
    });
    return;
  }

  @override
  void initState() {
    if (petIndex == -1) {
      newPet = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (assignPet) {
      context.read<FileController>().readPetDetails();
      
      pet = context.select((FileController controller) => controller.petDetails == null || controller.petDetails!.data.isEmpty) || newPet ? 
      Pet() : context.select((FileController controller) => controller.petDetails!.data[petIndex]);
      
      account = context.watch<FileController>().accountDetails != null ? context.watch<FileController>().accountDetails! : Account();
    
      // Defaults pet's owner to the account name if one is set.
      if (newPet && context.read<FileController>().accountDetails != null) { 
        if (context.read<FileController>().accountDetails!.name != null) pet.owner = context.read<FileController>().accountDetails!.name!;
      }

      assignPet = false;
    }

    Future<String> sharePetInfo(Pet? petToShare) async {
      if (petToShare == null) return "Error";
      petToShare.notOwnedByAccount = true;
      petToShare.sharedPrefVet = account.preferredVet;
      petToShare.sharedEmeVet = account.emergencyVet;

      var uuid = const Uuid();
      String filename = uuid.v4();
      filename = filename.replaceRange(6, filename.length, '');
      filename = filename.toUpperCase(); // Filename results in a random 6 character long code of numbers and letters. All letters are uppercase. 

      var headers = {
        'Content-Type': 'application/json',
        'x-ms-blob-type': 'BlockBlob'
      };
      var request = http.Request('PUT', Uri.parse('https://shareblobsaccount.blob.core.windows.net/petsharecontainer/$filename.json?sv=2022-11-02&ss=bf&srt=o&sp=wactfx&se=2025-10-01T08:19:27Z&st=2024-09-13T00:19:27Z&spr=https&sig=sF2pNHIdjPHa17nStOyabcxYwxTwnRGdxuQ9AC9XL2w%3D'));

      Future<String> base64FromImage(String imagePath) async {
        File imageFile = File(imagePath);
        Uint8List bytes = await imageFile.readAsBytes();
        return base64Encode(bytes);
      }

      if (petToShare.image != null) {
        petToShare.image = await base64FromImage(petToShare.image!);
      } 
      if (petToShare.vaccinations.isNotEmpty) {
        for (int i = 0; i < petToShare.vaccinations.length; i++) {
          if (petToShare.vaccinations[i].imagePath != "") petToShare.vaccinations[i].imagePath = await base64FromImage(petToShare.vaccinations[i].imagePath);
        }
      }
      if (petToShare.procedures.isNotEmpty) {
        for (int i = 0; i < petToShare.procedures.length; i++) {
          if (petToShare.procedures[i].imagePath != "") petToShare.procedures[i].imagePath = await base64FromImage(petToShare.procedures[i].imagePath);
        }
      }
      request.body = json.encode(petToShare);
      
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200)
      {
        //print(await response.stream.bytesToString());
        return filename;
      } 
      else {
        //print(response.reasonPhrase);
        return "Error";
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: ImageIcon(const Image(image: Svg('assets/petTetherIcon.svg')).image, size: 28,),
        elevation: 1,
        leading: BackButton(
          onPressed: () async {
            if (unsavedChanges) await saveChangesQuestion(context);
            if (context.mounted) Navigator.maybePop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: addOrEditPetData, 
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      floatingActionButton: !newPet ? FloatingActionButton(
        heroTag: "sharePetInfoBtn",
        onPressed: () async {
          if(NetworkUtil.acceptableRequestAmount())
          {
            if (unsavedChanges) await saveChangesQuestion(context);

            if (context.mounted) {
              String petCode = await sharePetInfo(context.read<FileController>().petDetails?.data[petIndex]);
              if (context.mounted) showPetCode(context, petCode);
            }
          }
          else {
            NetworkUtil.showTooManyRequests(context);
          }
        },
        child: const Icon(Icons.ios_share_rounded),
      ) : null,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            children: [
              basicInfoCard(),
              foodInfoCard(),
              medicalInfoCard(),
              emergencyInfo(),

              if (!newPet) IntrinsicHeight(
                child: Row(
                  children: [
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          confirmDelete(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          elevation: 1,
                        ),
                        child: Text(
                          "Delete Pet",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                  ],
                ),
              ),
            ],
          ),
          AnimatedOpacity(
            opacity: savedConfirmVisible ? 1 : 0,
            duration: savedConfirmVisible ? const Duration(milliseconds: 100) : const Duration(milliseconds: 1000),
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              alignment: Alignment.topCenter,
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                child: Container(
                  width: 74,
                  height: 30,
                  alignment: Alignment.center,
                  child: Text(
                    "Saved!", 
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirmDelete(BuildContext context) {
    return showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        titlePadding: const EdgeInsets.only(left: 24, top: 24),
        title: Text(
          "Delete Pet?", 
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(decoration: TextDecoration.underline),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Text(
          "Are you sure you want to delete this pet profile? This action cannot be undone.",
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
        buttonPadding: const EdgeInsets.all(0),
        actions: [
          TextButton(
            child: Text(
              "Cancel", 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 8.0),
          TextButton(
            style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.red)),
            child: Text(
              "Delete", 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            onPressed: () async {
              PetDetails? petDetails = context.read<FileController>().petDetails;

              if (pet.image != null) FileManager().deleteFile(pet.image);
              if (petDetails != null) petDetails.data.removeAt(petIndex);
            
              unsavedChanges = false;

              if (context.mounted) Navigator.of(context).pop();
              if (context.mounted) Navigator.of(context).pop();

              await context.read<FileController>().writePetDetails(petDetails!);
            },
          ),
        ],
      ),
    );
  }

  Future saveChangesQuestion(BuildContext context) {
    return showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        titlePadding: const EdgeInsets.only(left: 24, top: 24, bottom: 12),
        title: Text("Unsaved Changes", style: Theme.of(context).textTheme.headlineMedium),
        contentPadding: const EdgeInsets.all(20),
        content: Text(
          "You have unsaved changes, would you like to save your changes?",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
        buttonPadding: const EdgeInsets.all(0),
        actions: [
          TextButton(
            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onSurface)),
            child: Text("Save", style: TextStyle(color: Theme.of(context).colorScheme.surface),),
            onPressed: () async {
              await addOrEditPetData();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("No", style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> showPetCode(BuildContext context, String petCode) {
    return showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        titlePadding: const EdgeInsets.only(left: 24, top: 24, bottom: 12),
        title: const Text("Pet Code", style: TextStyle(decoration: TextDecoration.underline),),
        contentPadding: const EdgeInsets.all(20),
        content: Text(
          petCode,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            letterSpacing: 12,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 12, bottom: 12),
        buttonPadding: const EdgeInsets.all(0),
        actions: [
          TextButton(
            child: Text("CLOSE", style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<String?> displayBottomSheet(BuildContext context, {bool petImage = true}) {
    return showModalBottomSheet(
      context: context, 
      builder: (context) => SizedBox(
        height: 200,
        child: Column(
          children: [
            SizedBox(
              height: 99,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  selectImage(ImageSource.gallery, petImage: petImage).then((path) {
                    addOrEditPetData();
                    if (path != null) {
                      if (context.mounted) Navigator.pop(context, path);
                    }
                    else {
                      if (context.mounted) Navigator.pop(context);
                    }
                  });
                }, 
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.photo, color: Theme.of(context).colorScheme.onPrimary,),
                    ),
                    Text("Pick Photo", style: Theme.of(context).textTheme.headlineMedium,),
                  ],
                )
              ),
            ),
            const Divider(
              thickness: 2,
              indent: 18,
              endIndent: 18,
              height: 2,
            ),
            SizedBox(
              height: 99,
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  selectImage(ImageSource.camera, petImage: petImage).then((path) {
                    addOrEditPetData();
                    if (path != null) {
                      if (context.mounted) Navigator.pop(context, path);
                    }
                    else {
                      if (context.mounted) Navigator.pop(context);
                    }
                  });
                }, 
                style: ButtonStyle(
                    shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                    ),
                  ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.camera_alt_outlined, color: Theme.of(context).colorScheme.onPrimary,),
                    ),
                    Text("Take Photo", style: Theme.of(context).textTheme.headlineMedium,),
                  ],
                )
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget basicInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 270,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      displayBottomSheet(context);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Theme.of(context).colorScheme.onSurface,
                          backgroundImage: pet.image != null ? 
                          FileImage(File(pet.image!)) : null,
                        ),
                        Icon(
                          pet.image != null ? null : Icons.pets,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.start,
                              autocorrect: false,
                              maxLines: 1,
                              enabled: false,
        
                              onChanged: (text) {
                                unsavedChanges = true;
                                pet.age = text;
                              },
                              decoration: InputDecoration(
                                hintText: pet.age,
                                isDense: true,
                                disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface),
                                ),
                              ),
                            ),
                          ),
                          const Text("age", style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 140,
                            child: TextField(
                              keyboardType: TextInputType.none,
                              textAlign: TextAlign.start,
                              autocorrect: false,
                              maxLines: 1,
                              showCursor: false,
        
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          surface: Theme.of(context).colorScheme.primary,
                                          primary: Theme.of(context).colorScheme.onSurface,
                                          onSurface: Theme.of(context).colorScheme.onPrimary,
                                          onPrimary: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                  initialDate: pet.birthday == null ? DateTime.now() : DateFormat('dd/MM/yyyy').tryParse(pet.birthday!),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                ).then((date) {
                                  if (date != null) {
                                    unsavedChanges = true;
                                    setState(() {
                                      pet.birthday = DateFormat('dd/MM/yyyy').format(date);
                                      pet.age = context.read<FileController>().checkAndUpdatePetBirthdays(birthday: date, updateAll: false);
                                    });
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                hintText: pet.birthday,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Text("birthday", style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.name,
                              textAlign: TextAlign.end,
                              autocorrect: false,
                              maxLines: 1,
        
                              onChanged: (text) {
                                unsavedChanges = true;
                                pet.name = text;
                              },
                              decoration: InputDecoration(
                                hintText: pet.name,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Text("name", style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.name,
                              textAlign: TextAlign.end,
                              autocorrect: false,
                              maxLines: 1,
        
                              onChanged: (text) {
                                unsavedChanges = true;
                                pet.owner = text;
                              },
                              decoration: InputDecoration(
                                hintText: pet.owner,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Text("owner", style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.end,
                              autocorrect: false,
                              maxLines: 1,
        
                              onChanged: (text) {
                                unsavedChanges = true;
                                pet.gender = text;
                              },
                              decoration: InputDecoration(
                                hintText: pet.gender,
                                isDense: true,
                              ),
                            ),
                          ),
                          const Text("gender" , style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 30,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.end,
                                  autocorrect: false,
                                  maxLines: 1,
        
                                  onChanged: (text) {
                                    unsavedChanges = true;
                                    pet.species = text;
                                  },
                                  decoration: InputDecoration(
                                    hintText: pet.species,
                                    isDense: true,
                                  ),
                                ),
                              ),
        
                              const Text("/"),
        
                              SizedBox(
                                height: 30,
                                width: 70,
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.end,
                                  autocorrect: false,
                                  maxLines: 1,
        
                                  onChanged: (text) {
                                    unsavedChanges = true;
                                    pet.breed = text;
                                  },
                                  decoration: InputDecoration(
                                    hintText: pet.breed,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Text("species / breed" , style: TextStyle(color: Colors.grey), textScaler: TextScaler.linear(0.8),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool foodVisible = true;
  TextEditingController foodListInput = TextEditingController();
  TextEditingController foodNotesInput = TextEditingController();
  Widget foodInfoCard() {
    foodNotesInput.text = pet.petFoodNotes == null ? "" : pet.petFoodNotes!;
    Widget getFoods(int index) {
      if (pet.petFoods.isNotEmpty && index < pet.petFoods.length) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pet.petFoods[index], 
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  pet.petFoods.removeAt(index);
                  unsavedChanges = true;
                });
              }, 
              child: Icon(
                Icons.clear, 
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ],
        );
      }
      else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                onSubmitted: (value) {
                  if (value.isEmpty) return;
                  setState(() {
                    unsavedChanges = true;
                    pet.petFoods.add(value);
                    foodListInput.clear();
                  });
                },
                maxLines: 1,
                controller: foodListInput,
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: "Add Pet foods",
                  hintStyle: Theme.of(context).textTheme.bodySmall,
                  border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (foodListInput.text.isEmpty) return;
                setState(() {
                  unsavedChanges = true;
                  pet.petFoods.add(foodListInput.text);
                  foodListInput.clear();
                });
              }, 
              child: Icon(
                Icons.check, 
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ],
        );
      }
    }

    Widget getEatingTimes(int index) {
      void timePicker() async {
        final TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 0, minute: 0),
          initialEntryMode: TimePickerEntryMode.input,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  surface: Theme.of(context).colorScheme.primary,
                  primary: Theme.of(context).colorScheme.onSurface,
                  onSurface: Theme.of(context).colorScheme.onPrimary,
                  onPrimary: Theme.of(context).colorScheme.primary,
                ),
                timePickerTheme: TimePickerThemeData(
                  dayPeriodColor: Theme.of(context).colorScheme.onSurface,
                  dayPeriodTextColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).colorScheme.surface;
                    }
                    return Theme.of(context).colorScheme.onPrimary;
                  }),
                )
              ),
              child: child!,
            );
          },
        );
        if (newTime != null) {
          int compareTimeOfDay(TimeOfDay time1, TimeOfDay time2) {
            var totalMinutes1 = time1.hour * 60 + time1.minute;
            var totalMinutes2 = time2.hour * 60 + time2.minute;
            return totalMinutes1.compareTo(totalMinutes2);
          }
          pet.feedingTimes.add(newTime);
          pet.feedingTimes.sort(compareTimeOfDay);
          setState(() {
            unsavedChanges = true;
            pet.feedingTimes;
          });
        }
      }

      if (pet.feedingTimes.isNotEmpty && index < pet.feedingTimes.length) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              pet.feedingTimes[index].format(context), 
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  pet.feedingTimes.removeAt(index);
                  unsavedChanges = true;
                });
              }, 
              child: Icon(
                Icons.clear, 
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ],
        );
      }
      else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: timePicker,
                child: Text(
                  "Add Feeding Time",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            GestureDetector(
              onTap: timePicker, 
              child: Icon(
                Icons.add, 
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ],
        );
      }
    }

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        iconColor: Theme.of(context).colorScheme.onSurface,
        shape: const Border(),
        title: Text("Food", 
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        trailing: Icon(
          foodVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, 
          color: Theme.of(context).colorScheme.onPrimary, 
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            foodVisible = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Container(
              height: 234,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 1
                ),
              )
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // What they eat
                          Expanded(
                            child: /*InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8))),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8))),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)), ),
                                filled: true,
                                fillColor: const Color.fromARGB(8, 0, 0, 0),
                                contentPadding: const EdgeInsets.only(left: 4, right: 4, bottom: 4, top: 5),
                                labelText: "Pets Food",
                                alignLabelWithHint: true,
                                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                              ),
                              child: */ListView.builder(
                                itemCount: pet.petFoods.length + 1,
                                shrinkWrap: true,
                                itemBuilder: (context, index) => getFoods(index),
                              ),
                            //),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          // Notes/Routines
                          Expanded(
                            child: TextField(
                              controller: foodNotesInput,
                              maxLines: null,
                              minLines: 5,
                              autocorrect: true,
                              keyboardType: TextInputType.multiline,
                              style: Theme.of(context).textTheme.bodyMedium,
                              onChanged: (value) {
                                setState(() {
                                  unsavedChanges = true;
                                  pet.petFoodNotes = value;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8))),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8))),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)), ),
                                filled: true,
                                fillColor: const Color.fromARGB(8, 0, 0, 0),
                                contentPadding: const EdgeInsets.only(left: 4, right: 4, bottom: 4, top: 6),
                                labelText: "Notes",
                                alignLabelWithHint: true,
                                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Pet food image
                          Expanded(
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.2,
                                child: Image.asset('assets/images/petFoodBowl.png', width: 120,),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          // Feeding times
                          Expanded(
                            child: /*InputDecorator(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8))),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8))),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.8)), ),
                                filled: true,
                                fillColor: const Color.fromARGB(8, 0, 0, 0),
                                contentPadding: const EdgeInsets.only(left: 4, right: 4, bottom: 4, top: 6),
                                labelText: "Feeding Times",
                                alignLabelWithHint: true,
                                labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.secondary),
                              ),
                              child: */ListView.builder(
                                itemCount: pet.feedingTimes.length + 1,
                                shrinkWrap: true,
                                itemBuilder: (context, index) => getEatingTimes(index),
                              ),
                            //),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool timePicked = false;
  MedicationEntry newEntry = MedicationEntry(name: "", time: const TimeOfDay(hour: 0, minute: 0), taken: false);
  String newPathVac = "";
  String newPathPro = "";
  TextEditingController medicationsInput = TextEditingController();
  TextEditingController vaccinationsInput = TextEditingController();
  TextEditingController proceduresInput = TextEditingController();
  bool medicalVisible = true;
  bool vaccinationsVisible = false;
  bool proceduresVisible = false;
  Widget medicalInfoCard() {
    Widget getMedications(int index) {
      Future<TimeOfDay> timePicker() async {
        final TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 0, minute: 0),
          initialEntryMode: TimePickerEntryMode.input,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  surface: Theme.of(context).colorScheme.primary,
                  primary: Theme.of(context).colorScheme.onSurface,
                  onSurface: Theme.of(context).colorScheme.onPrimary,
                  onPrimary: Theme.of(context).colorScheme.primary,
                ),
                timePickerTheme: TimePickerThemeData(
                  dayPeriodColor: Theme.of(context).colorScheme.onSurface,
                  dayPeriodTextColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).colorScheme.surface;
                    }
                    return Theme.of(context).colorScheme.onPrimary;
                  }),
                )
              ),
              child: child!,
            );
          },
        );
        return newTime ?? const TimeOfDay(hour: 0, minute: 0);
      }
      void sortByTime() {
        pet.medications.sort((a, b) {
          // Convert TimeOfDay to minutes since midnight for comparison
          final aMinutes = a.time.hour * 60 + a.time.minute;
          final bMinutes = b.time.hour * 60 + b.time.minute;
          return aMinutes.compareTo(bMinutes);
        });
        setState(() {
          unsavedChanges = true;
          pet.medications;
        });
      }
      void resetOnSubmit() {
        timePicked = false;
        newEntry = MedicationEntry(name: "", time: const TimeOfDay(hour: 0, minute: 0), taken: false);
        medicationsInput.clear();
      }

      if (pet.medications.isNotEmpty && index < pet.medications.length) {
        return Dismissible(
          key: UniqueKey(),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            setState(() {
              pet.medications.removeAt(index);
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  pet.medications[index].name, 
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Text(
                pet.medications[index].time.format(context), 
                maxLines: 1,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.end,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 20,
                height: 24,
                child: Transform.scale(
                  scale: 0.8,
                  child: Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: pet.medications[index].taken, 
                    onChanged: (value) {
                      setState(() {
                        unsavedChanges = true;
                        pet.medications[index].taken = value ?? false;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }
      else {
        return Container(
          decoration: pet.medications.isNotEmpty ? BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  maxLines: 1,
                  controller: medicationsInput,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: "Add Medication",
                    hintStyle: Theme.of(context).textTheme.bodySmall,
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  newEntry.time = await timePicker();
                  setState(() {
                    newEntry.time;
                    timePicked = true;
                  });
                },
                child: timePicked
                ? Text(
                    newEntry.time.format(context),
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.end,
                  )
                : Text(
                    "12:00 AM",
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.end,
                  ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 20,
                child: GestureDetector(
                  onTap: () {
                    // need to do checks to ensure each variable is filled
                    if (medicationsInput.text.isEmpty || medicationsInput.text == "") return;

                    newEntry.name = medicationsInput.text;
                    setState(() {
                      unsavedChanges = true;
                      pet.medications.add(newEntry);
                    });
                    sortByTime();
                    resetOnSubmit();
                  }, 
                  child: Icon(
                    Icons.add, 
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    Widget getVaccinations(int index) {
      if (pet.vaccinations.isNotEmpty && index < pet.vaccinations.length) {
        return Dismissible(
          key: UniqueKey(),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            setState(() {
              pet.vaccinations.removeAt(index);
            });
          },
          child: Container(
            height: 30,
            margin: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pet.vaccinations[index].name, 
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          String? path = await displayBottomSheet(context, petImage: false);
                          if (path != null) pet.vaccinations[index].imagePath = path;
                        },
                        child: const Icon(
                          Icons.upload_file,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          if (pet.vaccinations[index].imagePath == "") return;

                          showDialog(
                            context: context, 
                            builder: (_) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Image.file(File(pet.vaccinations[index].imagePath))
                              )
                            ),
                          );
                        },
                        child: Icon(
                          Icons.view_in_ar_rounded,
                          size: 24,
                          color: pet.vaccinations[index].imagePath != "" ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
      else {
        return Container(
          margin: const EdgeInsets.only(left: 8, right: 8),
          decoration: pet.vaccinations.isNotEmpty ? BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  maxLines: 1,
                  controller: vaccinationsInput,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: "Add Vaccine",
                    hintStyle: Theme.of(context).textTheme.bodySmall,
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                  ),
                ),
              ),
              SizedBox(
                width: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String? path = await displayBottomSheet(context, petImage: false);
                        if (path != null) newPathVac = path;
                      },
                      child: Icon(
                        Icons.upload_file,
                        size: 22,
                        color: newPathVac != "" ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      child: const Icon(
                        Icons.add,
                        size: 24,
                      ),
                      onTap: () {
                        if (vaccinationsInput.text.isEmpty || vaccinationsInput.text == "") return;
                
                        setState(() {
                          pet.vaccinations.add(VaccinationEntry(
                            name: vaccinationsInput.text, 
                            imagePath: newPathVac,
                          ));
                        });
                        vaccinationsInput.clear();
                        newPathVac = "";
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    } 

    Widget getProcedures(int index) {
      if (pet.procedures.isNotEmpty && index < pet.procedures.length) {
        return Dismissible(
          key: UniqueKey(),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            setState(() {
              pet.procedures.removeAt(index);
            });
          },
          child: Container(
            height: 30,
            margin: const EdgeInsets.only(left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pet.procedures[index].name, 
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          String? path = await displayBottomSheet(context, petImage: false);
                          if (path != null) pet.procedures[index].imagePath = path;
                        },
                        child: const Icon(
                          Icons.upload_file,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          if (pet.procedures[index].imagePath == "") return;

                          showDialog(
                            context: context, 
                            builder: (_) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Image.file(File(pet.procedures[index].imagePath))
                              )
                            ),
                          );
                        },
                        child: Icon(
                          Icons.view_in_ar_rounded,
                          size: 24,
                          color: pet.procedures[index].imagePath != "" ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
      else {
        return Container(
          margin: const EdgeInsets.only(left: 8, right: 8),
          decoration: pet.procedures.isNotEmpty ? BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  maxLines: 1,
                  controller: proceduresInput,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: "Add Procedure",
                    hintStyle: Theme.of(context).textTheme.bodySmall,
                    border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
                  ),
                ),
              ),
              SizedBox(
                width: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String? path = await displayBottomSheet(context, petImage: false);
                        if (path != null) newPathPro = path;
                      },
                      child: Icon(
                        Icons.upload_file,
                        size: 22,
                        color: newPathPro != "" ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      child: const Icon(
                        Icons.add,
                        size: 24,
                      ),
                      onTap: () {
                        if (proceduresInput.text.isEmpty || proceduresInput.text == "") return;
                
                        setState(() {
                          pet.procedures.add(ProcedureEntry(
                            name: proceduresInput.text, 
                            imagePath: newPathPro,
                          ));
                        });
                        proceduresInput.clear();
                        newPathPro = "";
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }
    } 
    
    return Card(
      clipBehavior: Clip.hardEdge,
      child: ExpansionTile(
        initiallyExpanded: true,
        iconColor: Theme.of(context).colorScheme.onSurface,
        shape: const Border(),
        title: Text("Medical", 
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        trailing: Icon(
          medicalVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, 
          color: Theme.of(context).colorScheme.onPrimary, 
        ),
        onExpansionChanged: (bool expanded) {
          setState(() {
            medicalVisible = expanded;
          });
        },
        children: [
          Stack(
            children: [
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.only(left: 16, right: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              LimitedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      LimitedBox(
                        maxHeight: 90,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pet food image
                              SizedBox(
                                height: 90,
                                width: 90,
                                child: Center(
                                  child: Transform.rotate(
                                    angle: -0.4,
                                    child: Image.asset('assets/images/petNeedle.png'),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              // Notes/Routines
                              Expanded(
                                child: ClipRRect(
                                  clipBehavior: Clip.hardEdge,
                                  child: ListView.builder(
                                    itemCount: 1 + pet.medications.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) => getMedications(index),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      ExpansionTile(
                        initiallyExpanded: false,
                        iconColor: Theme.of(context).colorScheme.onSurface,
                        shape: const Border(),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        title: Text("Vaccinations", 
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                        ),
                        trailing: Icon(
                          vaccinationsVisible ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined, 
                          color: Theme.of(context).colorScheme.onPrimary, 
                        ),
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            vaccinationsVisible = expanded;
                          });
                        },
                        children: [
                          ClipRRect(
                            clipBehavior: Clip.hardEdge,
                            child: LimitedBox(
                              maxHeight: 200,
                              child: ListView.builder(
                                itemCount: 1 + pet.vaccinations.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) => getVaccinations(index),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ExpansionTile(
                        initiallyExpanded: false,
                        iconColor: Theme.of(context).colorScheme.onSurface,
                        shape: const Border(),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        childrenPadding: const EdgeInsets.only(bottom: 4),
                        title: Text("Procedures", 
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                        ),
                        trailing: Icon(
                          proceduresVisible ? Icons.arrow_drop_up_outlined : Icons.arrow_drop_down_outlined, 
                          color: Theme.of(context).colorScheme.onPrimary, 
                        ),
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            proceduresVisible = expanded;
                          });
                        },
                        children: [
                          ClipRRect(
                            clipBehavior: Clip.hardEdge,
                            child: LimitedBox(
                              maxHeight: 200,
                              child: ListView.builder(
                                itemCount: 1 + pet.procedures.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) => getProcedures(index),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget emergencyInfo() {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column (
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( // Title
                      "Preferred Vet",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text( // Preferred Vet Address
                      (pet.notOwnedByAccount 
                        ? formatAddressToPostal(pet.sharedPrefVet.address) 
                        : formatAddressToPostal(account.preferredVet.address) 
                      ) ?? "Please set preferred vet address\nfound in account settings.\n",
                      softWrap: true,
                      maxLines: 3,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          child: Icon(
                            Icons.directions,
                            color: (pet.notOwnedByAccount 
                                      ? pet.sharedPrefVet.address
                                      : account.preferredVet.address
                                    ) != null ?
                              Theme.of(context).colorScheme.onPrimary :
                              Theme.of(context).colorScheme.secondary,
                          ),
                          onTap: () async { // Directions Button
                            if ((pet.notOwnedByAccount ? pet.sharedPrefVet.address : account.preferredVet.address) != null)
                            {
                              Position? currentLocation = await NetworkUtil.determinePosition(context);
                              Uri url = Uri.https("www.google.com", "/maps/dir/", {
                                "api" : "1",
                                "origin" : "${currentLocation.latitude},${currentLocation.longitude}",
                                "destination" : pet.notOwnedByAccount 
                                                ? pet.sharedPrefVet.address
                                                : account.preferredVet.address,
                                "travelmode" : "driving",
                              });
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                if (kDebugMode) {
                                  print("Cannot launch url: $url");
                                }
                              }
                            }
                            else {
                              notification(context, "Error", "Please set your preferred vet's address before navigating.");
                            }
                          }, 
                        ),
                        const SizedBox(height: 16.0),
                        GestureDetector(
                          child: Icon(
                            Icons.phone,
                            color: (pet.notOwnedByAccount
                                    ? pet.sharedPrefVet.phoneNumber
                                    : account.preferredVet.phoneNumber
                                  ) != null ?
                              Theme.of(context).colorScheme.onPrimary :
                              Theme.of(context).colorScheme.secondary,
                          ),
                          onTap: () async { // Phone Call Button
                            if ((pet.notOwnedByAccount ? pet.sharedPrefVet.phoneNumber : account.preferredVet.phoneNumber) != null)
                            {
                              final Uri url = Uri(
                                scheme: 'tel',
                                path: pet.notOwnedByAccount
                                        ? pet.sharedPrefVet.phoneNumber
                                        : account.preferredVet.phoneNumber, // Preferred Vet phone number string
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                if (kDebugMode) {
                                  print("Cannot launch url: $url");
                                }
                              }
                            }
                            else {
                              notification(context, "Error", "Please set your preferred vet's phone number before calling.");
                            }
                          }, 
                        ),
                      ],
                    ),
                    const SizedBox(width: 8.0),
                    GestureDetector(
                      child: Container(
                        color: const Color.fromARGB(10, 0, 0, 0),
                        height: 80,
                        width: 80,
                        child: pet.notOwnedByAccount
                                ? pet.sharedPrefVet.locationImagePath != null ? Image.file(File(pet.sharedPrefVet.locationImagePath!)) : null
                                : account.preferredVet.locationImagePath != null ? Image.file(File(account.preferredVet.locationImagePath!)) : null
                      ),
                      onTap: () async { // Directions Button
                        if ((pet.notOwnedByAccount ? pet.sharedPrefVet.address : account.preferredVet.address) != null)
                        {
                          Position? currentLocation = await NetworkUtil.determinePosition(context);
                          Uri url = Uri.https("www.google.com", "/maps/dir/", {
                            "api" : "1",
                            "origin" : "${currentLocation.latitude},${currentLocation.longitude}",
                            "destination" : pet.notOwnedByAccount 
                                            ? pet.sharedPrefVet.address
                                            : account.preferredVet.address,
                            "travelmode" : "driving",
                          });
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (kDebugMode) {
                              print("Cannot launch url: $url");
                            }
                          }
                        }
                        else {
                          notification(context, "Error", "Please set your preferred vet's address before navigating.");
                        }
                      }, 
                    ),
                  ],
                ),
              ],
            ),
          
            Divider(
              height: 8.0, 
              thickness: 0.6,
              endIndent: 88.0, // Should be equal to the size of the container holding the map image + the padding of the card
              color: Theme.of(context).colorScheme.secondary,
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( // Title
                      "Emergency Vet",
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text( // Emergency Vet Address
                      (pet.notOwnedByAccount
                        ? formatAddressToPostal(pet.sharedEmeVet.address)
                        : formatAddressToPostal(account.emergencyVet.address)
                      ) ?? "Please set emergency vet address\nfound in account settings.\n",
                      softWrap: true,
                      maxLines: 3,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          child: Icon(
                            Icons.directions,
                            color: (pet.notOwnedByAccount
                                    ? pet.sharedEmeVet.address
                                    : account.emergencyVet.address 
                                  ) != null ?
                              Theme.of(context).colorScheme.onPrimary :
                              Theme.of(context).colorScheme.secondary,
                          ),
                          onTap: () async { // Directions Button
                            if ((pet.notOwnedByAccount ? pet.sharedEmeVet.address : account.emergencyVet.address) != null)
                            {
                              Position? currentLocation = await NetworkUtil.determinePosition(context);
                              Uri url = Uri.https("www.google.com", "/maps/dir/", {
                                "api" : "1",
                                "origin" : "${currentLocation.latitude},${currentLocation.longitude}",
                                "destination" : pet.notOwnedByAccount
                                                  ? pet.sharedEmeVet.address
                                                  : account.emergencyVet.address,
                                "travelmode" : "driving",
                              });
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                if (kDebugMode) {
                                  print("Cannot launch url: $url");
                                }
                              }
                            }
                            else {
                              notification(context, "Error", "Please set your emergency vet's address.\nIf this is an emergency see the emergency page for local vet clinics.");
                            }
                          }, 
                        ),
                        const SizedBox(height: 16.0),
                        GestureDetector(
                          child: Icon(
                            Icons.phone,
                            color: (pet.notOwnedByAccount
                                    ? pet.sharedEmeVet.phoneNumber
                                    : account.emergencyVet.phoneNumber
                                   ) != null ?
                              Theme.of(context).colorScheme.onPrimary :
                              Theme.of(context).colorScheme.secondary,
                          ),
                          onTap: () async { // Phone Call Button
                            if ((pet.notOwnedByAccount ? pet.sharedEmeVet.phoneNumber : account.emergencyVet.phoneNumber) != null)
                            {
                              final Uri url = Uri(
                                scheme: 'tel',
                                path: pet.notOwnedByAccount
                                        ? pet.sharedEmeVet.phoneNumber
                                        : account.emergencyVet.phoneNumber, // Emergency Vet phone number string
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                if (kDebugMode) {
                                  print("Cannot launch url: $url");
                                }
                              }
                            }
                            else {
                              notification(context, "Error", "Please set your emergency vet's phone number.\nIf this is an emergency see the emergency page for local vet clinics.");
                            }
                          }, 
                        ),
                      ],
                    ),
                    const SizedBox(width: 8.0),
                    GestureDetector(
                      child: Container(
                        color: const Color.fromARGB(10, 0, 0, 0),
                        height: 80,
                        width: 80,
                        child: pet.notOwnedByAccount
                                ? pet.sharedEmeVet.locationImagePath != null ? Image.file(File(pet.sharedEmeVet.locationImagePath!)) : null
                                : account.emergencyVet.locationImagePath != null ? Image.file(File(account.emergencyVet.locationImagePath!)) : null
                      ),
                      onTap: () async { // Directions Button
                        if ((pet.notOwnedByAccount ? pet.sharedEmeVet.address : account.emergencyVet.address) != null)
                        {
                          Position? currentLocation = await NetworkUtil.determinePosition(context);
                          Uri url = Uri.https("www.google.com", "/maps/dir/", {
                            "api" : "1",
                            "origin" : "${currentLocation.latitude},${currentLocation.longitude}",
                            "destination" : pet.notOwnedByAccount
                                              ? pet.sharedEmeVet.address
                                              : account.emergencyVet.address,
                            "travelmode" : "driving",
                          });
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            if (kDebugMode) {
                              print("Cannot launch url: $url");
                            }
                          }
                        }
                        else {
                          notification(context, "Error", "Please set your emergency vet's address.\nIf this is an emergency see the emergency page for local vet clinics.");
                        }
                      }
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

