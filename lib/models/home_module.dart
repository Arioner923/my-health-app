import 'package:flutter/material.dart';

/// Model class used for the Home Dashboard modules.
///
/// Each dashboard card needs:
/// - a title
/// - an icon
/// - a navigation route
///
/// Keeping this data inside a model makes the HomeScreen cleaner
/// and easier to maintain.
class HomeModule {
  final String title;
  final IconData icon;
  final String route;

  const HomeModule({
    required this.title,
    required this.icon,
    required this.route,
  });
}