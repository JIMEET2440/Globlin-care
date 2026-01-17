import 'package:flutter/material.dart';
import 'package:master_app/dashboard.dart';
import 'package:master_app/login.dart';
import 'package:master_app/main.dart';
import 'package:master_app/add_sales.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SalesPage(), // <--- Directly open the page you want to test
    ),
  );
}
