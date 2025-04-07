import 'package:flutter/material.dart';

// Central place to handle navigation logic
class NavigationService {
  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
  
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/login');
  }
}