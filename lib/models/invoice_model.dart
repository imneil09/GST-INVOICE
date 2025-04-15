import 'product_model.dart';

class InvoiceModel {
  // ✅ Constant Company Details (Header)
  static const String companyName = "M/S PARUL ENTERPRISE";
  static const String companyAddress =
      "Ward No-2, South Bejimara S.B. School, Sonamura, Sepahijala, Tripura";
  static const String gstin = "16BTBPD0736P1ZO";
  static const String invoiceTitle = "TAX INVOICE";

  // ✅ Invoice Details
  String invoiceNumber;
  static const String state = "TRIPURA(16)"; // Constant
  String invoiceDate;

  // ✅ Customer (Ship To) Details - User Input
  String customerName;
  String customerAddress;
  String customerPin;
  String outwardSupplies;
  String? customerGstin;

  // ✅ Product List - User Input
  List<Product> products;

  // ✅ Totals (Calculated)
  double allSubTotal = 0;
  double totalCGST = 0;
  double totalSGST = 0;
  double totalIGST = 0;
  double allTaxAmount = 0;

  // ✅ Constant Bank Details
  static const String bankAccountHolder = companyName;
  static const String bankAccountNumber = "3917322662";
  static const String bankBranchIfsc = "Sonamura & SBIN0006626";

  // ✅ Constant Declaration
  static const String declaration =
      "WE HEREBY DECLARE THAT THIS INVOICE REFLECTS THE TRUE AND ACCURATE PRICE OF THE PRODUCT(S) LISTED, AND THAT ALL INFORMATION PROVIDED IS CORRECT AND VERIFIED.";

  // ✅ Seal & Signature
  static const String signatureText = "$companyName\n(Authorized Signatory)";
  String sealImagePath;

  // ✅ Constructor
  InvoiceModel({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    required this.customerAddress,
    required this.customerPin,
    required this.outwardSupplies,
    this.customerGstin,
    required this.products,
    this.sealImagePath = "assets/SEAL.jpeg",
  }) {
    _calculateTotals(); // ✅ Calculate totals when invoice is created
  }

  // ✅ Method to calculate totals
  void _calculateTotals() {
    allSubTotal = 0;
    totalCGST = 0;
    totalSGST = 0;
    totalIGST = 0;
    allTaxAmount = 0;

    for (var product in products) {
      allSubTotal += product.subTotal;
      totalCGST += product.cgstAmount;
      totalSGST += product.sgstAmount;
      totalIGST += product.igstAmount;
      allTaxAmount += product.totalAmount;
    }
  }

  // ✅ Call this method whenever products are added/removed/updated
  void updateTotals() {
    _calculateTotals();
  }

  // ✅ Convert Number to Words (Static Method)
  static String convertNumberToWords(double amount) {
    if (amount == 0) return "Zero Rupees Only";

    List<String> units = [
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
    ];
    List<String> teens = [
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen",
    ];
    List<String> tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
      "Ninety",
    ];
    List<String> thousands = ["", "Thousand", "Lakh", "Crore"];
    List<int> divisors = [1000, 100, 100];

    int rupees = amount.toInt();
    String words = "";
    int place = 0;

    while (rupees > 0) {
      if (rupees % 1000 != 0) {
        words =
            "${helper(rupees % 1000, units, teens, tens)} ${thousands[place]} $words";
      }
      rupees ~/= divisors[place];
      place++;
    }

    if (words.trim().isEmpty) words = "Zero Rupees";

    words = "${words.trim()} Rupees Only";

    return words;
  }

  /// ✅ Helper function
  static String helper(
    int num,
    List<String> units,
    List<String> teens,
    List<String> tens,
  ) {
    if (num == 0) return "";
    if (num < 10) return units[num];
    if (num < 20) return teens[num - 10];
    if (num < 100) return "${tens[num ~/ 10]} ${units[num % 10]}".trim();
    return "${units[num ~/ 100]} Hundred ${helper(num % 100, units, teens, tens)}"
        .trim();
  }

  // ✅ Convert InvoiceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      "companyName": companyName,
      "companyAddress": companyAddress,
      "gstin": gstin,
      "invoiceTitle": invoiceTitle,
      "invoiceNumber": invoiceNumber,
      "state": state,
      "invoiceDate": invoiceDate,
      "customerName": customerName,
      "customerAddress": customerAddress,
      "customerPin": customerPin,
      "outwardSupplies": outwardSupplies,
      "customerGstin": customerGstin,
      "products": products.map((product) => product.toJson()).toList(),
      "allSubTotal": allSubTotal,
      "totalCGST": totalCGST,
      "totalSGST": totalSGST,
      "totalIGST": totalIGST,
      "allTaxAmount": allTaxAmount,
      "bankAccountHolder": bankAccountHolder,
      "bankAccountNumber": bankAccountNumber,
      "bankBranchIfsc": bankBranchIfsc,
      "declaration": declaration,
      "signatureText": signatureText,
      "sealImagePath": sealImagePath,
    };
  }
}
