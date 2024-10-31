import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pet_profile_app/account_details.dart';
import 'package:pet_profile_app/common/location_list_tile.dart';
import 'package:pet_profile_app/common/nearby_vets_tile.dart';
import 'package:pet_profile_app/file_controller.dart';
import 'package:pet_profile_app/utils/maps_util.dart';
import 'package:pet_profile_app/utils/network_util.dart';
import 'package:pet_profile_app/secrets.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class EmergencyView extends StatefulWidget {
  const EmergencyView({super.key});

  @override
  State<EmergencyView> createState() => EmergencyViewState();
}

class EmergencyViewState extends State<EmergencyView> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  static CameraPosition defaultCameraPosition = const CameraPosition(target: LatLng(0, 0));
  LatLng lastLatLng = const LatLng(0, 0);
  Set<Marker> markers = {};
  List<AutocompletePrediction> placePredictions = [];
  List<NearbyVets> nearbyVets = [];

  bool searchingForLocation = false;
  final TextEditingController _mapSearchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nearbyVets = context.watch<FileController>().accountDetails != null ? context.watch<FileController>().accountDetails!.nearbyVetsSaved : [];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
          right: 16,
          left: 16,
        ),
        child: Column(
          children: [
            // Search bar to enter location
            Material(
              elevation: 1,
              borderRadius: searchingForLocation ? 
                const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ) : 
                BorderRadius.circular(12.0),
              child: Container(
                decoration: ShapeDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: searchingForLocation ? 
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0), 
                        topRight: Radius.circular(12.0),
                      ),
                    ) : 
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        showCursor: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Enter your location...",
                          hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        controller: _mapSearchTextController,
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) async {

                          placePredictions = await mapPlaceAutoComplete(value);
                          setState(() {
                            placePredictions;
                          });
                          
                          if (value.isEmpty)
                          {
                            setState(() {
                              searchingForLocation = false;
                            });
                          }
                          else
                          {
                            setState(() {
                              searchingForLocation = true;
                            });
                          }
                        },
                        onSubmitted: (value) {
                          setState(() {
                            searchingForLocation = false;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _mapSearchTextController.clear();
                      }, 
                      icon: const Icon(Icons.clear),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: searchingForLocation ? 0.0 : 8.0),
            Expanded(
              child: Stack(
                fit: StackFit.loose,
                children: [
                  Column(
                    children: [
                      // Google Map Embed
                      Material(
                        elevation: 1,
                        borderRadius: BorderRadius.circular(12.0),
                        child: Container(
                          height: 300,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Scaffold(
                            body: GoogleMap(
                              mapType: MapType.terrain,
                              initialCameraPosition: defaultCameraPosition,
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              markers: markers,
                              onMapCreated: (GoogleMapController controller) async {
                                _mapController.complete(controller);

                                try {
                                  Position? lastKnownPos = await Geolocator.getLastKnownPosition();
                                  if (lastKnownPos != null) {
                                    controller.animateCamera(CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(lastKnownPos.latitude, lastKnownPos.longitude),
                                        zoom: 10,
                                      ))
                                    ); 
                                    lastLatLng = LatLng(lastKnownPos.latitude, lastKnownPos.longitude);
                                    NetworkUtil.lastLocation = lastKnownPos;
                                  }
                                } catch (e) {
                                  if (kDebugMode) {
                                    print(e);
                                  }
                                }
                              },
                            ),
                            floatingActionButton: FloatingActionButton.extended(
                              heroTag: "goToCurrentLocationBtn",
                              onPressed: goToLocation, 
                              label: const Icon(Icons.location_pin),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Nearby Emergency Vet Cards
                      Expanded(
                        child: Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(left: 12.0),
                              itemCount: nearbyVets.length,
                              itemBuilder: (context, index) => NearbyVetsTile(
                                businessName: nearbyVets[index].businessName,
                                formattedAddress: nearbyVets[index].formattedAddress,
                                phoneNumber: nearbyVets[index].phoneNumber,
                                isOpen: nearbyVets[index].isOpen,
                              )
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Search bar results
                  if (searchingForLocation) Container(
                    decoration: ShapeDecoration( 
                      color: Theme.of(context).colorScheme.primary,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0)))
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: placePredictions.length,
                      itemBuilder: (context, index) => LocationListTile(
                        indexPassed: index,
                        listLength: placePredictions.length,
                        location: placePredictions[index].description!,
                        press: () {
                          goToLocation(address: placePredictions[index].description!);
                          setState(() {
                            searchingForLocation = false;
                          });
                          FocusManager.instance.primaryFocus?.unfocus(); // Dismisses keyboard when a tile is clicked.
                          _mapSearchTextController.text = placePredictions[index].description!;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void determineIfSearchingAndSearch() async {
    Position? currentPos = await NetworkUtil.determinePosition(context);
    double distanceBetweenSavedAndCurrentPos = Geolocator.distanceBetween(
      lastLatLng.latitude, 
      lastLatLng.longitude, 
      
      currentPos.latitude,
      currentPos.longitude
    );
    if (distanceBetweenSavedAndCurrentPos > 2000) {
      mapPlaceNearbySearch();
    } else {
      if (nearbyVets.isNotEmpty && nearbyVets[0].formattedAddress != null) {
        NearbyVets location = nearbyVets[0];
        List<Location> locationList = await locationFromAddress(location.formattedAddress!); 
        LatLng nearbySavedVet = LatLng(locationList[0].latitude, locationList[0].longitude);

        double distanceBetweenNearbyVetAndCurrentPos = Geolocator.distanceBetween(
          nearbySavedVet.latitude, 
          nearbySavedVet.longitude, 
          
          currentPos.latitude,
          currentPos.longitude
        );

        if (distanceBetweenNearbyVetAndCurrentPos > 5000) {
          mapPlaceNearbySearch();
        }
      }
    }
  }

  void mapPlaceNearbySearch() async {
    Uri uri = Uri.https("places.googleapis.com", "/v1/places:searchNearby");
    Map<String, dynamic> jsonRequest = {
      "includedTypes": [
        "veterinary_care"
      ],
      "maxResultCount": 8,
      "locationRestriction": {
        "circle": {
          "center": {
            "latitude": NetworkUtil.lastLocation!.latitude,
            "longitude": NetworkUtil.lastLocation!.longitude
          },
          "radius": 7500
        }
      }
    };
    final String jsonRequestString = jsonEncode(jsonRequest);

    String? response = await NetworkUtil.fetchUrl(
      uri, 
      headers: {
        "Content-Type": "application/json", 
        "X-Goog-Api-Key": mapsAPI,
        "X-Goog-FieldMask": "places.displayName.text,places.formattedAddress,places.nationalPhoneNumber,places.regularOpeningHours.openNow",
        "Accept": "application/json",
        },
      jsonRequestBody: jsonRequestString
    );

    if (response != null && response.isNotEmpty) {
      NearbyVetsResponse result = NearbyVetsResponse.parseNearbyVetsResult(response);
      if(result.places != null) {
        // Sorts the list into true, false order based on 'isOpen' so that open business are shown before closed ones.
        result.places!.sort((a, b) {
          if (a.isOpen == null) return 1;
          if (b.isOpen == null) return -1;
          if (a.isOpen! && !b.isOpen!) return -1;
          if (!a.isOpen! && b.isOpen!) return 1;
          return 0;
        });

        nearbyVets = result.places!;
        if (!mounted) return;
        Account account = context.read<FileController>().accountDetails!;
        account.nearbyVetsSaved = nearbyVets;
        context.read<FileController>().writeAccountDetails(account);

        return;
      }
    }
  }


  Future<void> goToLocation({String? address}) async {
    final GoogleMapController mapController = await _mapController.future;
    markers.clear();

    LatLng goTo;
    if (address != null) {
      List<Location> locationList = await locationFromAddress(address);
      goTo = LatLng(locationList[0].latitude, locationList[0].longitude);


      NetworkUtil.lastLocation = Position(
        latitude: locationList.first.latitude,
        longitude: locationList.first.longitude,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 1.0, 
        altitudeAccuracy: 0.0, 
        headingAccuracy: 0.0,
      );
    }
    else {
      // ignore: use_build_context_synchronously
      Position position = await NetworkUtil.determinePosition(context);
      goTo = LatLng(position.latitude, position.longitude);
    }

    await mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: goTo,
        zoom: 10,
      ))); 

    markers.add(Marker(
        markerId: const MarkerId("CurrentLocation"),
        position: goTo,
      ));

    // if savedlocation is far enough away from current location
    double distanceBetweenSavedAndCurrentPos = Geolocator.distanceBetween(
      lastLatLng.latitude, 
      lastLatLng.longitude, 
      
      goTo.latitude,
      goTo.longitude
    );
    if (distanceBetweenSavedAndCurrentPos > 2000) {  // If new location is more than 1000 meters from old location.
      mapPlaceNearbySearch();
    }

    setState(() {
      lastLatLng = goTo;
    });
  }
}