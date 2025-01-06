import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatelessWidget {
  final String paymentUrl;

  const PaymentScreen({super.key, required this.paymentUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Gateway'),
      ),
      body: WebView(
        initialUrl: paymentUrl,
        javascriptMode: JavaScriptMode.unrestricted,
        onPageFinished: (url) {
          if (url.contains('payment_success')) {
            Navigator.pop(context, 'success'); // Handle success
          } else if (url.contains('payment_failed')) {
            Navigator.pop(context, 'failed'); // Handle failure
          }
        },
      ),
    );
  }
  
  WebView({required String initialUrl, required JavaScriptMode javascriptMode, required Null Function(dynamic url) onPageFinished}) {}
  
}