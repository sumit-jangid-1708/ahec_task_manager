import 'dart:io';
import 'package:ahec_task_manager/res/components/widgets/app_text_field.dart';
import 'package:ahec_task_manager/res/components/widgets/searchable_dropdown.dart';
import 'package:ahec_task_manager/view_models/controller/list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../view_models/controller/client_controller.dart';
import '../../view_models/controller/order_controller.dart';

class CreateOrderForm extends StatefulWidget {
  const CreateOrderForm({super.key});

  @override
  State<CreateOrderForm> createState() => _CreateOrderFormState();
}

class _CreateOrderFormState extends State<CreateOrderForm> {
  late final OrderController controller;
  late final ListController listController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OrderController>();
    listController = Get.find<ListController>();

    // Load all clients across all pages for the client dropdown
    final clientController = Get.find<ClientController>();
    if (clientController.userRmId.value != 0) {
      clientController.getAllClientsForDropdown();
    }
  }

  TextStyle label() =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  Widget buildDropdownTile(
      String title,
      RxString selected,
      List<String> list,
      Function(String) onSelect,
      ) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: label()),
          GestureDetector(
            onTap: () {
              if (list.isEmpty) {
                Get.snackbar(
                  "Info",
                  "$title is loading, please wait...",
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }
              Get.dialog(SearchableDropDown(
                title: title,
                list: list,
                onSelect: onSelect,
              ));
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selected.value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add Order",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F63F4),
                  ),
                ),
                const SizedBox(height: 20),

                // Client dropdown
                buildDropdownTile(
                  "Client",
                  controller.clientSelected,
                  controller.clientDropdownList,
                      (value) => controller.clientSelected.value = value,
                ),

                // Order Type
                buildDropdownTile(
                  "Order Type",
                  controller.orderTypeSelected,
                  controller.orderTypeList,
                      (value) => controller.orderTypeSelected.value = value,
                ),

                // Order ID - only shown for existing orders
                Obx(() {
                  if (controller.orderTypeSelected.value == "Existing Order") {
                    return buildDropdownTile(
                      "Order ID",
                      controller.orderIdSelected,
                      controller.orderIdList,
                          (value) => controller.orderIdSelected.value = value,
                    );
                  }
                  controller.orderIdSelected.value = "Select Order ID";
                  return const SizedBox.shrink();
                }),

                // Payment Type
                buildDropdownTile(
                  "Payment Type",
                  controller.paymentTypeSelected,
                  controller.paymentTypeList,
                      (value) => controller.paymentTypeSelected.value = value,
                ),

                // Service Type
                buildDropdownTile(
                  "Service Type",
                  controller.serviceTypeSelected,
                  listController.serviceList,
                      (value) => controller.serviceTypeSelected.value = value,
                ),

                Text("Module Code", style: label()),
                AppTextField(
                    controller: controller.moduleCode,
                    hint: "Enter module code"),
                const SizedBox(height: 12),

                Text("Module Name", style: label()),
                AppTextField(
                    controller: controller.moduleName,
                    hint: "Enter module name"),
                const SizedBox(height: 12),

                Text("Deadline", style: label()),
                GestureDetector(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      controller.deadline.text =
                      "${picked.day}-${picked.month}-${picked.year}";
                    }
                  },
                  child: AbsorbPointer(
                    child: AppTextField(
                        controller: controller.deadline,
                        hint: "Select deadline"),
                  ),
                ),
                const SizedBox(height: 12),

                Text("Word Count", style: label()),
                AppTextField(controller: controller.wordCount, hint: "0"),
                const SizedBox(height: 12),

                Text("Type", style: label()),
                AppTextField(controller: controller.type, hint: "Type"),
                const SizedBox(height: 12),

                // Currency
                buildDropdownTile(
                  "Currency",
                  controller.currencySelected,
                  listController.currencyList,
                      (value) => controller.currencySelected.value = value,
                ),

                Text("Client Amount", style: label()),
                AppTextField(
                    controller: controller.clientAmount,
                    hint: "Client Amount"),
                const SizedBox(height: 12),

                Text("INR Amount", style: label()),
                AppTextField(
                    controller: controller.inrAmount, hint: "INR Amount"),
                const SizedBox(height: 12),

                Text("AUD Amount", style: label()),
                AppTextField(
                    controller: controller.audAmount, hint: "AUD Amount"),
                const SizedBox(height: 12),

                // RM ID - read-only, auto-selected from logged-in user
                Text("RM ID", style: label()),
                const SizedBox(height: 8),
                Obx(() {
                  final rmList = controller.rmList;
                  final selected = controller.rmIdSelected.value;

                  return GestureDetector(
                    onTap: () {
                      if (rmList.isEmpty) {
                        Get.snackbar(
                          "Info",
                          "RM list is loading, please wait...",
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      Get.dialog(SearchableDropDown(
                        title: "Select RM",
                        list: rmList,
                        onSelect: (value) {
                          controller.rmIdSelected.value = value;
                        },
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF3F63F4)),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selected.isNotEmpty ? selected : "Loading RM...",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF3F63F4)),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Short Note
                Text("Short Note", style: label()),
                const SizedBox(height: 6),
                TextField(
                  controller: controller.shortNote,
                  maxLines: 3,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter short note",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Color(0xFF3F63F4)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Screenshot
                Text("Payment Screenshot", style: label()),
                const SizedBox(height: 8),
                Obx(() {
                  final img = controller.paymentImage.value;
                  return GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                      );
                      if (picked != null) {
                        controller.paymentImage.value = File(picked.path);
                      }
                    },
                    child: Container(
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                        color: Colors.white,
                      ),
                      child: img == null
                          ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 30, color: Colors.grey),
                            SizedBox(height: 6),
                            Text("Upload Payment Screenshot"),
                          ],
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(img, fit: BoxFit.cover),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                Text("Transaction ID", style: label()),
                AppTextField(
                    controller: controller.transactionId,
                    hint: "Transaction ID"),
                const SizedBox(height: 25),

                // Submit button
                SizedBox(
                  width: 120,
                  height: 45,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.submitOrder(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F63F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : const Text("Submit",
                        style: TextStyle(color: Colors.white)),
                  )),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}