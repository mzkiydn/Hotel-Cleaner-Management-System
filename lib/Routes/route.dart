import 'package:flutter/material.dart';
import 'package:hcms_sep/Views/Register/loginInterface.dart';
import 'package:hcms_sep/Views/Register/registerInterface.dart';
import 'package:hcms_sep/Views/Report/reportView.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/report': (context) => ReportView(),
    '/register': (context) => RegisterInterface(),
    '/login': (context) => LoginInterface(),
  };
}