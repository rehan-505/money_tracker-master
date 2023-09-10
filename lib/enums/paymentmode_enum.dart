import 'package:flutter/material.dart';
enum PaymentMode { cash, card, bank }

Map<PaymentMode,Color> paymentModeColorMap = {
  PaymentMode.cash: Colors.green,
  PaymentMode.card: Colors.blue,
  PaymentMode.bank: Colors.pink,
};