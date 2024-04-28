import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Position? _previousPosition;
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  Set<Marker> _markers = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
    _updateLocationPeriodically();
  }

  Future<void> _getCurrentPosition() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _updateMap(position);
  }

  void _updateLocationPeriodically() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _getCurrentPosition();
    });
  }

  void _updateMap(Position position) {
    _previousPosition = _currentPosition;
    _currentPosition = position;
    _updateMarker(position);
    _updatePolyline(position);
    _animateCurrentLocation();
    setState(() {});
  }

  void _updateMarker(Position position) {
    _markers.clear();

    if (_previousPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('previousLocation'),
          position: LatLng(_previousPosition!.latitude, _previousPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
          title: 'My Current Location',
          snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
        ),
        draggable: true
      ),
    );
  }

  void _updatePolyline(Position position) {
    LatLng newLatLng = LatLng(position.latitude, position.longitude);
    _polylineCoordinates.add(newLatLng);
    Polyline polyline = Polyline(
        polylineId: const PolylineId('polyline'),
        color: Colors.blue,
        points: _polylineCoordinates);

    _polylines.clear();
    _polylines.add(polyline);
  }

  void _animateCurrentLocation() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map & Location Tracker'),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
            target: LatLng(
                _currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 16.0),
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
