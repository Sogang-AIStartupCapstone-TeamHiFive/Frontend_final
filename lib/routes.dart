import 'package:flutter/material.dart';
import 'home.dart';
import 'createPage.dart';


final Map<String, WidgetBuilder> routes = {
  '/home': (context) => Home(),
  '/Create': (context) => CreatePage(),
};