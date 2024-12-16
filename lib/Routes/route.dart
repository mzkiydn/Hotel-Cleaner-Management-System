import 'package:flutter/material.dart';
import 'package:hcms_sep/Views/Report/reportView.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/report': (context) => ReportView(),
  };
}