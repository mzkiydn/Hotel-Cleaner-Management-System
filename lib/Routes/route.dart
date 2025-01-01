import 'package:flutter/material.dart';
import 'package:hcms_sep/Views/Register/loginInterface.dart';
import 'package:hcms_sep/Views/Report/reportView.dart';
import 'package:hcms_sep/Views/Activity/activityListView.dart';
import 'package:hcms_sep/Views/Activity/activityUpdateView.dart';
import 'package:hcms_sep/Views/Activity/bookingListView.dart';
import 'package:hcms_sep/Views/Activity/bookingRescheduleView.dart';



class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/login': (context) => LoginInterface(),
    '/report': (context) => ReportView(),
    '/activity': (context) => ActivityListView(),
    '/update': (context) => const ActivityUpdateView(),
    '/bookings': (context) => const BookingListView(),
    '/reschedule': (context) => const BookingRescheduleView(),
  };
}