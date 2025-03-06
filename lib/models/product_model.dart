/// 📌 Generic Product Model
class Product {
  String name;
  String hsnCode;
  double price;
  int quantity;
  double taxRate;
  bool isInterState; // ✅ True = IGST, False = CGST/SGST
  String unit; // ✅ Added unit (kg, pcs, etc.)

  Product({
    required this.name,
    required this.hsnCode,
    required this.price,
    required this.quantity,
    required this.taxRate,
    this.isInterState = false,
    required this.unit,
  });

  double get subTotal => price * quantity;

  // ✅ Tax calculations inside Product class
  double get cgstAmount => isInterState ? 0 : (subTotal * taxRate / 200);
  double get sgstAmount => isInterState ? 0 : (subTotal * taxRate / 200);
  double get igstAmount => isInterState ? (subTotal * taxRate / 100) : 0;
  double get totalAmount => double.parse(
    (subTotal + cgstAmount + sgstAmount + igstAmount).toStringAsFixed(2),
  );
  // ✅ Convert Product to JSON
Map<String, dynamic> toJson() {
  return {
    "name": name,
    "hsnCode": hsnCode,
    "price": price,
    "quantity": quantity,
    "taxRate": taxRate,
    "isInterState": isInterState,
    "unit": unit,
    "subTotal": subTotal,
    "cgstAmount": cgstAmount,
    "sgstAmount": sgstAmount,
    "igstAmount": igstAmount,
    "totalAmount": totalAmount,
  };
}

}
