part of 'navigation_bloc.dart';

@immutable
abstract class NavigationEvent {}

class StartNavigation extends NavigationEvent {
  final LatLng workerInitialLocation;
  final LatLng hirerLocation;

  StartNavigation({required this.workerInitialLocation, required this.hirerLocation});
}

class LocationUpdated extends NavigationEvent {
  final Position newPosition;

  LocationUpdated({required this.newPosition});
}

class RecenterMap extends NavigationEvent {}
