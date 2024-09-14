import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:pet_profile_app/common/location_list_tile.dart';
import 'package:pet_profile_app/common/nearby_vets_tile.dart';
import 'package:pet_profile_app/network_util.dart';
import 'package:pet_profile_app/secrets.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyView extends StatefulWidget {
  const EmergencyView({super.key});

  @override
  State<EmergencyView> createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView> {
  
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();



  static CameraPosition defaultCameraPosition = NetworkUtil.lastLocation == null ? 
  const CameraPosition(
    target: LatLng(-33.8688, 151.2093),
    zoom: 10,
  ) : 
  CameraPosition(
    target: LatLng(NetworkUtil.lastLocation!.latitude, NetworkUtil.lastLocation!.longitude),
    zoom: 10,
  );
  LatLng lastLatLng = const LatLng(0, 0);

  Set<Marker> markers = {};
  List<AutocompletePrediction> placePredictions = [];
  List<NearbyVets> nearbyVets = [];

  bool searchingForLocation = false;
  final TextEditingController _mapSearchTextController = TextEditingController();

  @override
  void initState() {
    goToLocation();
    mapPlaceNearbySearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            Container(
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: searchingForLocation ? 
                const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0))) : 
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
                        hintText: "Enter your location...",
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      controller: _mapSearchTextController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        mapPlaceAutoComplete(value);
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
            Expanded(
              child: Stack(
                fit: StackFit.loose,
                children: [
                  Column(
                    children: [
                      // Google Map Embed
                      Container(
                        margin: const EdgeInsets.only(top: 8),
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
                            markers: markers,
                            onMapCreated: (GoogleMapController controller) {
                              _mapController.complete(controller);
                            },
                          ),
                          floatingActionButton: FloatingActionButton.extended(
                            onPressed: goToLocation, 
                            label: const Icon(Icons.location_pin),
                          ),
                        ),
                      ),
                      // Nearby Emergency Vet Cards
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
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


  void mapPlaceAutoComplete(String query) async {
    Uri uri = Uri.https(
      "maps.googleapis.com", 
      "/maps/api/place/autocomplete/json",
      {
        "input": query,
        "key": mapsAPI,
      }
    );

    String? response = await NetworkUtil.fetchUrl(uri);
    if (response != null && response.isNotEmpty) {
      PlaceAutocompleteResponse result = PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if(result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }
  }

  void mapPlaceNearbySearch() async {
    Uri uri = Uri.https("places.googleapis.com", "/v1/places:searchNearby");
    Map<String, dynamic> jsonRequest = {
      "includedTypes": [
        "veterinary_care"
      ],
      "maxResultCount": 10,
      "locationRestriction": {
        "circle": {
          "center": {
            "latitude": lastLatLng.latitude,
            "longitude": lastLatLng.longitude
          },
          "radius": 50000
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
        setState(() {
          nearbyVets = result.places!;
        });
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
    }
    else {
      Position position = await NetworkUtil.determinePosition();
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
    
    setState(() {
      lastLatLng = goTo;
    });
    mapPlaceNearbySearch();
  }
}