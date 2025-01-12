import 'package:flutter/material.dart';
import 'package:hcms_sep/Views/Register/homestayRegistration.dart';
import 'package:hcms_sep/Views/Register/loginInterface.dart';
import 'package:hcms_sep/Views/Register/registerInterface.dart';
import 'package:hcms_sep/Views/Report/reportDetail.dart';
import 'package:hcms_sep/Views/Report/reportView.dart';
import 'package:hcms_sep/Views/Activity/activityListView.dart';
import 'package:hcms_sep/Views/Activity/activityUpdateView.dart';
//import 'package:hcms_sep/Views/Activity/bookingListView.dart';
import 'package:hcms_sep/Views/Activity/bookingRescheduleView.dart';
import 'package:hcms_sep/Views/Booking/BookingForm.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginInterface(),
    '/register': (context) => RegisterInterface(),
    '/report': (context) => ReportView(),
    '/activity': (context) => const ActivityListView(),
    '/update': (context) => const ActivityUpdateView(),
    '/booking': (context) => const BookingForm(),
    '/reschedule': (context) => const BookingRescheduleView(),
    '/homeregister': (context) => HomestayRegistration(),
    '/reportDetail': (context) {
      final report = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      return ReportDetail(report: report);
    },
  };
}
