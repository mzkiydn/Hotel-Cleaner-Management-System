import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
  
  
  
  static String secret = "sk_test_CsnggH3iChIYjrFoue5y6M98";
  static Map<String, String> headers = {
    "Authorization": 'Bearer ${StripeService.secret}',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  static init(){
    Stripe.publishableKey = 'pk_test_iO0OmHJjHiksR0HjyoUOSMNS0017Q3B9xA';
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
    String amount, String currency) async {
    try{
      Map<String, dynamic> body = {
        'amount' : amount,
        'currency' : currency,
        'payment_method_types[]' : 'card'
      };

      var response = await http.post(
        Uri.parse(StripeService.paymentApiUrl),
        body: body,
        headers: StripeService.headers,
      );

      return jsonDecode(response.body);
    }catch(e){
      throw Exception("Failed to create payment intent");
    }
  }

  static Future<void> initPaymentSheet(String amount, String currency)async{
    try{
      //create payment intent
      final paymentIntent = await createPaymentIntent(amount, currency);

      //initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent['client_secret'],
        merchantDisplayName: "Dear Programmer",
        style: ThemeMode.system,
        ),
      );
    }catch(e){
      throw Exception("Failed to initialize payment sheet");
    }
  }

  static Future<void> presentPaymentSheet()async{
    try{
      await Stripe.instance.presentPaymentSheet();
    }catch(e){
      throw Exception("Failed to initialize payment sheet");
    }
  }
}