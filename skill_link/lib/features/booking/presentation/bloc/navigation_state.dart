part of 'navigation_bloc.dart';

@immutable
abstract class NavigationState {}

class NavigationInitial extends NavigationState {}

class NavigationLoading extends NavigationState {}

class NavigationLoaded extends NavigationState {
  final List<LatLng> routePoints;
  final LatLng workerLocation;
  final LatLng hirerLocation;
  final bool shouldAnimateCamera;

  NavigationLoaded({
    required this.routePoints,
    required this.workerLocation,
    required this.hirerLocation,
    this.shouldAnimateCamera = false,
  });

  NavigationLoaded copyWith({
    List<LatLng>? routePoints,
    LatLng? workerLocation,
    bool? shouldAnimateCamera,
  }) {
    return NavigationLoaded(
      routePoints: routePoints ?? this.routePoints,
      workerLocation: workerLocation ?? this.workerLocation,
      hirerLocation: hirerLocation, // Stays constant
      shouldAnimateCamera: shouldAnimateCamera ?? this.shouldAnimateCamera,
    );
  }
}

class NavigationError extends NavigationState {
  final String message;

  NavigationError({required this.message});
}
