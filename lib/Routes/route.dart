import 'package:flutter/material.dart';
import 'package:hcms_sep/Domain/Report.dart';
import 'package:hcms_sep/Views/Activity/bookingListView.dart';
import 'package:hcms_sep/Views/Register/homestayListView.dart';
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
import 'package:hcms_sep/Views/Booking/BookingForm.dart';

import '../Provider/ActivityController.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (context) => const LoginInterface());
      case '/register':
        return MaterialPageRoute(builder: (context) => RegisterInterface());
      case '/report':
        return MaterialPageRoute(builder: (context) => ReportView());
      case '/activity':
      // Pass the controller here along with homestayId
        return MaterialPageRoute(
          builder: (context) => ActivityListView(
            controller: ActivityController(), // Provide the controller
          ),
        );
      case '/updateActivity':
      // Ensure the controller is passed here too
        return MaterialPageRoute(
          builder: (context) => ActivityUpdateView(
            homestayId: '', // Provide the homestayId
            controller: ActivityController(), // Provide the controller
          ),
        );
      case '/booking':
        return MaterialPageRoute(builder: (context) => const BookingForm());
      case '/bookinglistview':
        return MaterialPageRoute(builder: (context) => BookingListView());
      case '/reschedule':
        return MaterialPageRoute(builder: (context) => const BookingRescheduleView(bookingId: '',));
      case '/homeregister':
        return MaterialPageRoute(builder: (context) => HomestayRegistration());
      case '/homelist':
        return MaterialPageRoute(builder: (context) => HomestayListView());
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
