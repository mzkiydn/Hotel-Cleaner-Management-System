import 'package:flutter/material.dart';
import 'package:hcms_sep/Domain/Report.dart';
import 'package:hcms_sep/Views/Booking/BookingForm.dart';
import 'package:hcms_sep/Views/Register/homestayRegistration.dart';
import 'package:hcms_sep/Views/Register/loginInterface.dart';
import 'package:hcms_sep/Views/Register/registerInterface.dart';
import 'package:hcms_sep/Views/Report/reportDetail.dart';
import 'package:hcms_sep/Views/Report/reportPreview.dart';
import 'package:hcms_sep/Views/Report/reportView.dart';
import 'package:hcms_sep/Views/Activity/activityListView.dart';
import 'package:hcms_sep/Views/Activity/activityUpdateView.dart';
//import 'package:hcms_sep/Views/Activity/bookingListView.dart';
import 'package:hcms_sep/Views/Activity/bookingRescheduleView.dart';
import 'package:hcms_sep/Views/Booking/MyBookingPage.dart';
import 'package:hcms_sep/Views/Booking/Home.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (context) => HomePage());
      case '/login':
        return MaterialPageRoute(builder: (context) => const LoginInterface());
      case '/register':
        return MaterialPageRoute(builder: (context) => RegisterInterface());
      case '/report':
        return MaterialPageRoute(builder: (context) => ReportView());
      case '/activity':
        return MaterialPageRoute(
            builder: (context) => const ActivityListView());
      case '/update':
        return MaterialPageRoute(
            builder: (context) => const ActivityUpdateView());
      case '/booking':
        return MaterialPageRoute(builder: (context) => MyBookingPage());
      case '/bookingForm':
        return MaterialPageRoute(builder: (context) => const BookingForm());
      case '/reschedule':
        return MaterialPageRoute(
            builder: (context) => const BookingRescheduleView());
      case '/homeregister':
        return MaterialPageRoute(builder: (context) => HomestayRegistration());
      case '/reportDetail':
        final Report report = settings.arguments as Report;
        return MaterialPageRoute(
          builder: (context) => ReportDetail(report: report),
        );
      case '/reportPreview':
        final Report report = settings.arguments as Report;
        return MaterialPageRoute(
          builder: (context) => ReportPreview(report: report),
        );
      default:
        return MaterialPageRoute(builder: (context) => const LoginInterface());
    }
  }
}
