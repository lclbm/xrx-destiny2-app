import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xrx/layout_screen.dart';
import 'package:xrx/membership_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (_) => MembershipNotifier(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blueAccent,
          secondaryHeaderColor: Colors.blueAccent.shade700,
          elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle()),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SafeArea(child: LayoutScreen()),
      )));
}
