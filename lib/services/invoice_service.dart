import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/invoice_model.dart';

class InvoiceService {
  static Future<void> createInvoicePDF(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Extract data from the map
    final companyName = data['companyName'];
    final companyAddress = data['companyAddress'];
    final gstin = data['gstin'];
    final invoiceTitle = data['invoiceTitle'];
    final invoiceNumber = data['invoiceNumber'];
    final state = data['state'];
    final invoiceDate = data['invoiceDate'];
    final customerName = data['customerName'];
    final customerAddress = data['customerAddress'];
    final customerPin = data['customerPin'];
    final outwardSupplies = data['outwardSupplies'];
    final customerGstin = data['customerGstin'];
    final products = List<Map<String, dynamic>>.from(data['products']);
    final allSubTotal = data['allSubTotal'];
    final totalCGST = data['totalCGST'];
    final totalSGST = data['totalSGST'];
    final totalIGST = data['totalIGST'];
    final allTaxAmount = data['allTaxAmount'];
    final bankAccountHolder = data['bankAccountHolder'];
    final bankAccountNumber = data['bankAccountNumber'];
    final bankBranchIfsc = data['bankBranchIfsc'];
    final declaration = data['declaration'];
    final signatureText = data['signatureText'];
    // final sealImagePath = data['sealImagePath'];
    final sealImageBytes = await rootBundle.load('assets/SEAL.jpeg');

    // Try loading the seal image if the file exists
    // pw.Widget? sealImageWidget;
    // if (sealImagePath != null && File(sealImagePath).existsSync()) {
    //   final Uint8List sealBytes = File(sealImagePath).readAsBytesSync();
    //   sealImageWidget = pw.Image(pw.MemoryImage(sealBytes), width: 100);
    // }

    /// ✅ Convert Amount to Words
    String getAmountInWords() {
      return InvoiceModel.convertNumberToWords(allTaxAmount);
    }

    // Helper function for table rows
    pw.TableRow row(String header, double? value, {bool isBold = false}) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text(
              header,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text(
              (value ?? 0.0).toStringAsFixed(2),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }

    // Helper function for table rows
    pw.TableRow tableRow(String header, String value) {
      return pw.TableRow(
        children: [
          pw.Padding(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text(
              header,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(5),
            child: pw.Text(value, style: pw.TextStyle(fontSize: 10)),
          ),
        ],
      );
    }

    pw.Widget tableHeaderCell(String text) {
      return pw.Container(
        padding: pw.EdgeInsets.all(4),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      );
    }

    pw.Widget tableCell(String text) {
      return pw.Container(
        padding: pw.EdgeInsets.all(4),
        height: 250, // Keeps row height fixed to utilize empty space
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.left,
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(13),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 1, color: PdfColors.black),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Section
                pw.Container(
                  padding: pw.EdgeInsets.all(8),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("GSTIN: $gstin"),
                          pw.Text(
                            invoiceTitle,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 13), // Space between rows
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // COMPANY DETAILS (Multi-line Address)
                          pw.Expanded(
                            child: pw.Container(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    companyName,
                                    style: pw.TextStyle(
                                      fontSize: 17,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    companyAddress,
                                    textAlign: pw.TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // INVOICE DETAILS TABLE
                          pw.Container(
                            width: 200, // Set fixed width to prevent overflow
                            // ignore: deprecated_member_use
                            child: pw.Table.fromTextArray(
                              border: pw.TableBorder.all(
                                width: 1,
                                color: PdfColors.black,
                              ),
                              headers: ["INVOICE NUMBER", "DATE"],
                              data: [
                                [invoiceNumber, invoiceDate],
                              ],
                              headerStyle: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.black,
                              ),
                              headerDecoration: pw.BoxDecoration(
                                color: PdfColors.blue100,
                              ),
                              cellAlignment: pw.Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Buyer and Supply Info
                pw.Container(
                  // ignore: deprecated_member_use
                  child: pw.Table.fromTextArray(
                    border: pw.TableBorder.all(
                      width: 1,
                      color: PdfColors.black,
                    ),
                    headers: ["BUYER", "PLACE OF SUPPLY"],
                    data: [
                      [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("NAME : $customerName"),
                            pw.Text("ADDRESS : $customerAddress"),
                            pw.Text("PIN : $customerPin"),
                            if (customerGstin != null &&
                                customerGstin.isNotEmpty)
                              pw.Text(
                                "GSTIN : $customerGstin($outwardSupplies)",
                              ),
                          ],
                        ),
                        pw.Text(state),
                      ],
                    ],
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                    headerAlignment:
                        pw
                            .Alignment
                            .centerLeft, // Aligns header text to the left
                    cellAlignment:
                        pw.Alignment.topLeft, // Aligns cell content to the left
                  ),
                ),

                // Table for Products
                // ignore: deprecated_member_use
                pw.Table(
                  border: pw.TableBorder.all(
                    width: 0.5,
                    color: PdfColors.black,
                  ),
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        for (var header in [
                          "SL No",
                          "DESCRIPTION",
                          "HSN",
                          "QTY",
                          "UNIT",
                          "PRICE",
                          "AMOUNT",
                          "TAX",
                          "CGST",
                          "SGST",
                          "IGST",
                          "TOTAL",
                        ])
                          tableHeaderCell(header),
                      ],
                    ),

                    // Single Data Row (All products in one row, using extra space)
                    pw.TableRow(
                      children: [
                        for (var column in [
                          products
                              .asMap()
                              .entries
                              .map((entry) => (entry.key + 1).toString())
                              .join("\n\n"),
                          products.map((p) => p['name']).join("\n\n"),
                          products.map((p) => p['hsnCode'] ?? '').join("\n\n"),
                          products
                              .map((p) => p['quantity']?.toString() ?? '0')
                              .join("\n\n"),
                          products.map((p) => p['unit'] ?? '').join("\n\n"),
                          products
                              .map(
                                (p) => (p['price'] ?? 0.0).toStringAsFixed(2),
                              )
                              .join("\n\n"),
                          products
                              .map(
                                (p) =>
                                    (p['subTotal'] ?? 0.0).toStringAsFixed(2),
                              )
                              .join("\n\n"),
                          products
                              .map((p) => "${p['taxRate'] ?? 0}%")
                              .join("\n\n"),
                          products
                              .map(
                                (p) =>
                                    (p['cgstAmount'] ?? 0.0).toStringAsFixed(2),
                              )
                              .join("\n\n"),
                          products
                              .map(
                                (p) =>
                                    (p['sgstAmount'] ?? 0.0).toStringAsFixed(2),
                              )
                              .join("\n\n"),
                          products
                              .map(
                                (p) =>
                                    (p['igstAmount'] ?? 0.0).toStringAsFixed(2),
                              )
                              .join("\n\n"),
                          products
                              .map(
                                (p) => (p['totalAmount'] ?? 0.0)
                                    .toStringAsFixed(2),
                              )
                              .join("\n\n"),
                        ])
                          tableCell(column), // Use the helper function
                      ],
                    ),
                  ],
                ),

                // Total Amounts Section
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Container()), // Left half empty
                    pw.Container(
                      width: 200, // Adjust width as needed
                      child: pw.Table(
                        border: pw.TableBorder.all(
                          width: 0.5,
                          color: PdfColors.black,
                        ),
                        columnWidths: {
                          0: pw.FlexColumnWidth(2), // Header column width
                          1: pw.FlexColumnWidth(3), // Value column width
                        },
                        children: [
                          row("AMOUNT", allSubTotal),
                          row("CGST", totalCGST),
                          row("SGST", totalSGST),
                          row("IGST", totalIGST),
                          row(
                            "TOTAL",
                            (allTaxAmount is double)
                                ? allTaxAmount.roundToDouble()
                                : double.tryParse(allTaxAmount.toString()) ??
                                    0.0,
                            isBold: true,
                          ),
                          // Total row in bold
                        ],
                      ),
                    ),
                  ],
                ),

                // Amount in Words
                pw.SizedBox(
                  width: double.infinity, // Ensures full width
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1, color: PdfColors.black),
                    ),
                    child: pw.Text(
                      "IN WORD : ${getAmountInWords()}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ),

                // Bank Details
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1, // Adjust width as needed
                      child: pw.Container(
                        child: pw.Table(
                          border: pw.TableBorder.all(
                            width: 0.5,
                            color: PdfColors.black,
                          ),
                          columnWidths: {
                            0: pw.FlexColumnWidth(2), // Header column width
                            1: pw.FlexColumnWidth(3), // Value column width
                          },
                          children: [
                            tableRow("Bank Account Holder", bankAccountHolder),
                            tableRow("Account Number", bankAccountNumber),
                            tableRow("IFSC", bankBranchIfsc),
                          ],
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.SizedBox(),
                    ), // Empty space on the right
                  ],
                ),

                // DECLARATION
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1, color: PdfColors.black),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // First Column: "DECLARATION" with Background Color
                      pw.Container(
                        width: 100, // Adjust width as needed
                        height: 50, // Adjust height dynamically if needed
                        alignment:
                            pw
                                .Alignment
                                .center, // Centers text in both directions
                        decoration: pw.BoxDecoration(
                          color:
                              PdfColors
                                  .black, // Background color for full height
                        ),
                        child: pw.Text(
                          "DECLARATION",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            fontSize: 10,
                          ),
                          textAlign:
                              pw
                                  .TextAlign
                                  .center, // Ensures text is centered horizontally
                        ),
                      ),
                      // Second Column: Declaration Value (Multi-line)
                      pw.Expanded(
                        child: pw.Container(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            declaration,
                            textAlign:
                                pw
                                    .TextAlign
                                    .justify, // Makes text more readable
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Signatory Section
                // Add spacer before this section to push it to the bottom
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Column(
                    crossAxisAlignment:
                        pw
                            .CrossAxisAlignment
                            .center, // Aligns content to the right
                    children: [
                      // if (sealImageWidget != null)
                      //   pw.Container(
                      //     margin: pw.EdgeInsets.only(
                      //       bottom: 8,
                      //     ), // Adds spacing below the seal
                      //     child: sealImageWidget, // Seal Image
                      //   ),
                      pw.Image(
                        pw.MemoryImage(sealImageBytes.buffer.asUint8List()),
                        width: 100,
                      ),

                      pw.Container(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          signatureText,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Get the correct directory and create 'Invoices' folder
    Directory directory = await getApplicationDocumentsDirectory();
    Directory invoiceDir = Directory("${directory.path}/Invoices");
    if (!invoiceDir.existsSync()) {
      invoiceDir.createSync(recursive: true);
    }

    // Save the PDF inside 'Invoices' folder
    final filePath = "${invoiceDir.path}/Invoice_$invoiceNumber.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    OpenFile.open(filePath);
  }
}
