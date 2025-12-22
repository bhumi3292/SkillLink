import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:skill_link/core/services/location_service.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final LocationService _locationService;
  StreamSubscription<Position>? _positionSubscription;

  NavigationBloc(this._locationService) : super(NavigationInitial()) {
    on<StartNavigation>(_onStartNavigation);
    on<LocationUpdated>(_onLocationUpdated);
    on<RecenterMap>(_onRecenterMap);
  }

  Future<void> _onStartNavigation(
    StartNavigation event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationLoading());
    try {
      final routePoints = await _getRoute(event.workerInitialLocation, event.hirerLocation);
      emit(NavigationLoaded(
        routePoints: routePoints,
        workerLocation: event.workerInitialLocation,
        hirerLocation: event.hirerLocation,
        shouldAnimateCamera: true, // Animate to the initial position
      ));

      _positionSubscription?.cancel();
      _positionSubscription = _locationService.getPositionStream().listen((position) {
        add(LocationUpdated(newPosition: position));
      });
    } catch (e) {
      emit(NavigationError(message: 'Failed to get route: ${e.toString()}'));
    }
  }

  void _onLocationUpdated(LocationUpdated event, Emitter<NavigationState> emit) {
    if (state is NavigationLoaded) {
      final currentState = state as NavigationLoaded;
      emit(currentState.copyWith(
        workerLocation: LatLng(event.newPosition.latitude, event.newPosition.longitude),
        shouldAnimateCamera: true, // Always animate on location update
      ));
    }
  }

  void _onRecenterMap(RecenterMap event, Emitter<NavigationState> emit) {
    if (state is NavigationLoaded) {
      final currentState = state as NavigationLoaded;
      // Re-emit the same state but with shouldAnimateCamera set to true
      emit(currentState.copyWith(shouldAnimateCamera: true));
    }
  }

  Future<List<LatLng>> _getRoute(LatLng start, LatLng end) async {
    final dio = Dio();
    final url = 'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline';
    
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200 && response.data['routes'] != null && response.data['routes'].isNotEmpty) {
        final geometry = response.data['routes'][0]['geometry'];
        final polylinePoints = PolylinePoints();
        final result = polylinePoints.decodePolyline(geometry);
        return result.map((point) => LatLng(point.latitude, point.longitude)).toList();
      } else {
        throw Exception('Failed to fetch route from OSRM');
      }
    } catch (e) {
      throw Exception('Failed to connect to OSRM: ${e.toString()}');
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
