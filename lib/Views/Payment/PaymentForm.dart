import 'package:flutter/material.dart';
import 'package:hcms_sep/stripe_service.dart';

class PaymentForm extends StatefulWidget{
  const PaymentForm ({super.key});

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm>{

  String amount = '5000';
  String currency = 'MYR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stripe Payment"),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async{
                try{
                  await StripeService.initPaymentSheet(amount, currency);
                  await StripeService.presentPaymentSheet();
                }catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")));
                }
              },
              child: Text("Pay \$50"))
          ],
        ),
        ),
    );
  }
  
}