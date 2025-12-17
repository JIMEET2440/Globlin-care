import 'package:flutter/material.dart';
import 'package:master_app/login.dart';
import 'package:master_app/main.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),   // <--- Directly open the page you want to test
  ));
}
