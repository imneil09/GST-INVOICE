import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../controllers/model_controller.dart';
import '../models/invoice_model.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final InvoiceController controller = Get.put(InvoiceController());
  String _currentTime = '';
  String _currentDate = '';
  DateTime selectedDate = DateTime.now();
  String selectedSupplyType = 'B2C';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('hh:mm a | EEEE').format(now);
      _currentDate = DateFormat('dd MMM, yyyy').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Adjusted for proper fit
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF34B21),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _currentTime,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          _currentDate,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      InvoiceModel.companyName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          InvoiceModel.companyAddress,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(width: 13),
                        Text(
                          'GSTIN: ${InvoiceModel.gstin}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildInvoiceDetails(
                selectedDate: selectedDate,
                onDatePick: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      controller.invoiceDateController.text = DateFormat(
                        'dd/MM/yyyy',
                      ).format(selectedDate);
                    });
                  }
                },
              ),
              _buildCustomerDetails(
                selectedSupplyType: selectedSupplyType,
                onSupplyTypeChanged: (value) {
                  setState(() {
                    selectedSupplyType = value ?? selectedSupplyType;
                    controller.outwardSuppliesController.text =
                        selectedSupplyType;
                  });
                },
              ),
              _buildProductTable(),
              _buildTotalSection(),
              SizedBox(height: 23),
              _buildGeneratePdfButton(),
              SizedBox(height: 23),
              Text(
                '© 2025 M/S PARUL ENTERPRISE | DESIGN & DEVELOPED BY SAGAR BHOWMIK',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(179, 73, 71, 71),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ INVOICE DETAILS
  Widget _buildInvoiceDetails({
    required DateTime selectedDate,
    required Function() onDatePick,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.invoiceNumberController,
                decoration: InputDecoration(labelText: 'Invoice Number'),
                keyboardType: TextInputType.text,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Invoice Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: onDatePick,
                controller: TextEditingController(
                  text: DateFormat('dd/MM/yyyy').format(selectedDate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ CUSTOMER DETAILS
  Widget _buildCustomerDetails({
    required String selectedSupplyType,
    required Function(String?) onSupplyTypeChanged,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.customerNameController,
                    decoration: InputDecoration(labelText: 'Customer Name'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSupplyType,
                    items:
                        ['B2C', 'B2B'].map((String type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged: onSupplyTypeChanged,
                    decoration: InputDecoration(labelText: 'Outward Supplies'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controller.customerAddressController,
                    decoration: InputDecoration(labelText: 'Customer Address'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller.customerPinController,
                    decoration: InputDecoration(labelText: 'Pin Code'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: controller.customerGstinController,
                        decoration: InputDecoration(
                          labelText: 'GSTIN (Optional)',
                        ),
                      ),
                      if (selectedSupplyType == 'B2C')
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                          child: Text(
                            'GSTIN is required for B2B',
                            style: TextStyle(fontSize: 9, color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ PRODUCT TABLE & ADD PRODUCT
  Widget _buildProductTable() {
    return Card(
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            title: Text(
              'PRODUCTS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: ElevatedButton(
              onPressed: _showProductEntryDialog,
              child: Text('Add Product'),
            ),
          ),
          Obx(
            () =>
                controller.products.isEmpty
                    ? Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No products added.'),
                    )
                    : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Product')),
                          DataColumn(label: Text('HSN Code')),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Price')),
                          DataColumn(label: Text('Tax Rate')),
                          DataColumn(label: Text('CGST')),
                          DataColumn(label: Text('SGST')),
                          DataColumn(label: Text('IGST')),
                          DataColumn(label: Text('Total')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows:
                            controller.products.map((product) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(product.name)),
                                  DataCell(Text(product.hsnCode)),
                                  DataCell(Text(product.quantity.toString())),
                                  DataCell(
                                    Text(
                                      '₹${product.price.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  DataCell(Text('${product.taxRate}%')),
                                  DataCell(
                                    Text(
                                      '₹${product.cgstAmount.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '₹${product.sgstAmount.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '₹${product.igstAmount.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '₹${product.totalAmount.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed:
                                              () => _showProductEntryDialog(
                                                editProduct: product,
                                              ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => controller.removeProduct(
                                                controller.products.indexOf(
                                                  product,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  // ✅ PRODUCT ENTRY DIALOG
  void _showProductEntryDialog({Product? editProduct}) {
    TextEditingController nameController = TextEditingController(
      text: editProduct?.name ?? "",
    );
    TextEditingController hsnController = TextEditingController(
      text: editProduct?.hsnCode ?? "",
    );
    TextEditingController priceController = TextEditingController(
      text: editProduct?.price.toString() ?? "",
    );
    TextEditingController quantityController = TextEditingController(
      text: editProduct?.quantity.toString() ?? "",
    );

    // Rx variables for real-time UI updates
    RxString selectedUnit = (editProduct?.unit ?? 'Cartons').obs;
    RxDouble selectedTaxRate = (editProduct?.taxRate ?? 5.0).obs;
    RxBool isInterState = (editProduct?.isInterState ?? false).obs;

    Get.defaultDialog(
      title: editProduct == null ? "Add Product" : "Edit Product",
      content: Obx(
        () => Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: hsnController,
              decoration: InputDecoration(labelText: "HSN Code"),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: "Quantity"),
              keyboardType: TextInputType.number,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Unit",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedUnit.value,
                  items:
                      ['Cartons', 'Bags', 'KG', 'Liters', 'PCS']
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) selectedUnit.value = value;
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tax Rate",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                DropdownButton<double>(
                  value: selectedTaxRate.value,
                  items:
                      [5.0, 9.0, 12.0, 18.0, 28.0]
                          .map(
                            (rate) => DropdownMenuItem(
                              value: rate,
                              child: Text('$rate%'),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) selectedTaxRate.value = value;
                  },
                ),
              ],
            ),
            CheckboxListTile(
              title: Text("Interstate Transaction (IGST)"),
              value: isInterState.value,
              onChanged: (value) {
                if (value != null) isInterState.value = value;
              },
            ),
          ],
        ),
      ),
      textConfirm: editProduct == null ? "Add Product" : "Update Product",
      onConfirm: () {
        try {
          String name = nameController.text.trim();
          String hsnCode = hsnController.text.trim();
          double price = double.tryParse(priceController.text) ?? 0.0;
          int quantity = int.tryParse(quantityController.text) ?? 0;
          String unit = selectedUnit.value;

          if (name.isEmpty || hsnCode.isEmpty || price <= 0 || quantity <= 0) {
            throw Exception("Invalid input values.");
          }

          Product newProduct = Product(
            name: name,
            hsnCode: hsnCode,
            price: price,
            quantity: quantity,
            unit: unit,
            taxRate: selectedTaxRate.value,
            isInterState: isInterState.value,
          );

          if (editProduct == null) {
            controller.addProduct(newProduct);
          } else {
            int index = controller.products.indexWhere(
              (p) => p.name == editProduct.name,
            );
            if (index != -1) controller.updateProduct(index, newProduct);
          }

          Get.back();
        } catch (e) {
          Get.snackbar('Error', 'Please enter valid product details.');
        }
      },
    );
  }

  // ✅ TOTAL AMOUNT
  Widget _buildTotalSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(13),
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => Text(
                  'Total Amount: ₹ ${controller.totalAmount.value.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              Obx(
                () => Text(
                  'In Words: ${controller.getAmountInWords().toUpperCase()}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ GENERATE PDF
  Widget _buildGeneratePdfButton() {
    return Center(
      child: ElevatedButton(
        // ignore: avoid_print
        onPressed: (){
          InvoiceModel invoiceData = controller.generateInvoice();
          controller.generatePdf(invoiceData);
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 20,
          ), // Increase button size
          backgroundColor: Color(0xFFF34B21),
          minimumSize: Size(200, 60), // Set a minimum size
          elevation: 8, // Increase elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
        ),
        child: Text(
          'Save as PDF',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
