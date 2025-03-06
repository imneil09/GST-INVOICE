import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/invoice_model.dart';
import '../models/product_model.dart';
import '../services/invoice_service.dart';

class InvoiceController extends GetxController {
  // ✅ Invoice Details
  final invoiceNumberController = TextEditingController();
  final invoiceDateController = TextEditingController();

  // ✅ Customer Details
  final customerNameController = TextEditingController();
  final customerAddressController = TextEditingController();
  final customerPinController = TextEditingController();
  final outwardSuppliesController = TextEditingController();
  final customerGstinController = TextEditingController();
  final isInterState = false.obs; // ✅ Inter-State Toggle

  // ✅ Product List
  final products = <Product>[].obs;

  // ✅ Totals (Auto-Updated)
  final totalSubTotal = 0.0.obs;
  final totalCGST = 0.0.obs;
  final totalSGST = 0.0.obs;
  final totalIGST = 0.0.obs;
  final totalAmount = 0.0.obs;

  /// ✅ Set Customer Details
  void setCustomerDetails({
    required String name,
    required String address,
    required String pin,
    required String outwardSupply,
    String? gstin,
    bool? interState = false, // Default value set
  }) {
    customerNameController.text = name;
    customerAddressController.text = address;
    customerPinController.text = pin;
    outwardSuppliesController.text = outwardSupply;
    customerGstinController.text = gstin ?? '';
    isInterState.value = interState ?? false; // Direct assignment

    _calculateTotals();
  }

  /// ✅ Product Management
  void addProduct(Product product) =>
      _updateProductList(() => products.add(product));

  void updateProduct(int index, Product updatedProduct) {
    if (index < products.length) {
      _updateProductList(() => products[index] = updatedProduct);
    }
  }

  void removeProduct(int index) {
    if (index < products.length) {
      _updateProductList(() => products.removeAt(index));
    }
  }

  void _updateProductList(VoidCallback action) {
    action();
    _calculateTotals();
  }

  /// ✅ Calculate Totals
  void _calculateTotals() {
    totalSubTotal.value = products.fold(0.0, (sum, p) => sum + p.subTotal);
    totalCGST.value = products.fold(0.0, (sum, p) => sum + p.cgstAmount);
    totalSGST.value = products.fold(0.0, (sum, p) => sum + p.sgstAmount);
    totalIGST.value = products.fold(0.0, (sum, p) => sum + p.igstAmount);
    totalAmount.value =
        totalSubTotal.value +
        totalCGST.value +
        totalSGST.value +
        totalIGST.value;

    update(); // ✅ Notify UI
  }

  /// ✅ Convert Amount to Words
  String getAmountInWords() {
    return InvoiceModel.convertNumberToWords(totalAmount.value);
  }

  /// ✅ Generate Invoice Object
  InvoiceModel generateInvoice() => InvoiceModel(
    invoiceNumber: invoiceNumberController.text,
    invoiceDate: invoiceDateController.text,
    customerName: customerNameController.text,
    customerAddress: customerAddressController.text,
    customerPin: customerPinController.text,
    outwardSupplies: outwardSuppliesController.text,
    customerGstin:
        customerGstinController.text.isEmpty
            ? null
            : customerGstinController.text,
    products: products,
  );

  /// ✅ Generate PDF Invoice (Placeholder)
  void generatePdf(InvoiceModel invoiceData) {
    var data = invoiceData.toJson();
    InvoiceService.createInvoicePDF(data);
    // print("THE INVOICE DATA ARE AS BELOW:\n${invoiceData.toJson()}");
    Get.snackbar(
      "PDF",
      "Invoice PDF generated successfully!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// ✅ Cleanup
  @override
  void onClose() {
    for (var controller in [
      invoiceNumberController,
      invoiceDateController,
      customerNameController,
      customerAddressController,
      customerPinController,
      outwardSuppliesController,
      customerGstinController,
    ]) {
      controller.dispose();
    }
    super.onClose();
  }
}
