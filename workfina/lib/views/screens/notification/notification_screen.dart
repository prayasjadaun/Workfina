import 'package:flutter/material.dart';
import 'package:workfina/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NOTIFICATIONS"),
        backgroundColor: AppTheme.primary),
      body: Container(),
    );
  }
}
