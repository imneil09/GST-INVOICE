import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gstinvoice/views/invoice_screen.dart';

void main() {
  runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GST INVOICE',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InvoiceScreen(),
    ));
}
