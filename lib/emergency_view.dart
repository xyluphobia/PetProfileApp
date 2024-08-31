import 'dart:async';
import 'package:pet_profile_app/common/location_list_tile.dart';
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

  static const CameraPosition defaultCameraPosition = CameraPosition(
    target: LatLng(-33.8688, 151.2093),
    zoom: 10,
  );

  Set<Marker> markers = {};

  TextEditingController mapSearchController = TextEditingController();

  @override
  void initState() {
    goToCurrentLocation();
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: null,
                      controller: mapSearchController,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      mapPlaceAutoComplete("Sydney");
                    }, 
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            // Search bar results (make it go on top of all other elements & make it only appear when searching)
            LocationListTile(
              location: "Test Location, Test Area, Testing",
              press: () {},
            ),
            // Google Map Embed
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              clipBehavior: Clip.antiAlias,
              height: 300,
              child: GoogleMap(
                mapType: MapType.terrain,
                initialCameraPosition: defaultCameraPosition,
                zoomControlsEnabled: false,
                markers: markers,
                onMapCreated: (GoogleMapController controller) {
                  _mapController.complete(controller);
                },
              ),
            ),
            // Nearby Emergency Vet Cards
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToCurrentLocation, 
        label: const Icon(Icons.location_pin),
      ),
    );
  }


  void mapPlaceAutoComplete(String query) async {
    Uri uri = Uri.https(
      "places.googleapis.com", 
      "/v1/places:autocomplete",
      {
        "input": query,
        "key": mapsAPI,
      }
    );

    String? response = await NetworkUtil.fetchUrl(uri);
    if (response != null && response.isNotEmpty) {
      print(response);
    }
  }


  Future<void> goToCurrentLocation() async {
    final GoogleMapController mapController = await _mapController.future;
    Position position = await _determinePosition();

    await mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 10,
    ))); 

    markers.clear();
    markers.add(Marker(
      markerId: const MarkerId("CurrentLocation"),
      position: LatLng(position.latitude, position.longitude),
    ));

    setState(() {
    });
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}