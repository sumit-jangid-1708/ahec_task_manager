import 'package:ahec_task_manager/res/components/widgets/app_text_field.dart';
import 'package:ahec_task_manager/res/components/widgets/searchable_dropdown.dart';
import 'package:ahec_task_manager/view_models/controller/client_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class AddClientForm extends StatefulWidget {
  const AddClientForm({super.key});

  @override
  State<AddClientForm> createState() => _AddClientFormState();
}

class _AddClientFormState extends State<AddClientForm> {
  final ClientController clientController = Get.find<ClientController>();

  // String rmIdSelected = "Select RM ID";
  // String? phoneNumber;
  // String? countryCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F63F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Get.isSnackbarOpen) {
              Get.closeCurrentSnackbar();
            }
            Navigator.of(context).pop();
          },
        ),
        title: Text("Add New Client", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Obx(() {
          // Show loading while RM list is being fetched
          if (clientController.isLoading.value &&
              clientController.rmList.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Client Information",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F63F4),
                    ),
                  ),
                  SizedBox(height: 30),

                  Text("First Name", style: _labelStyle()),
                  AppTextField(hint: 'First Name', controller: clientController.firstName.value),

                  SizedBox(height: 16),
                  Text("Last Name", style: _labelStyle()),
                  AppTextField(hint: 'Last Name', controller:clientController.lastName.value),

                  SizedBox(height: 16),
                  Text("Email", style: _labelStyle()),
                  AppTextField(hint: 'Email', controller: clientController.email.value),

                  SizedBox(height: 16),
                  Text("Phone Number", style: _labelStyle()),
                  IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: "Mobile No.",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    initialCountryCode: 'IN',
                    onChanged: (phone) {
                      clientController.phoneNumber.value = phone.number;
                      clientController.countryCode.value = phone.countryCode;
                    },
                  ),

                  SizedBox(height: 16),
                  Text("University Name", style: _labelStyle()),
                  AppTextField(
                    hint: 'University Name',
                    controller: clientController.universityName.value,
                  ),

                  SizedBox(height: 16),
                  Text("RM ID", style: _labelStyle()),
                  SizedBox(height: 8),

                  // Non-editable field (sirf dikhao, click na ho)
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            clientController.rmIdSelected.value,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                        Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  )),
                  // ✅ Updated RM ID Dropdown with API data
                  // GestureDetector(
                  //   onTap: () {
                  //     if (clientController.rmList.isEmpty) {
                  //       Get.snackbar(
                  //         "Info",
                  //         "RM list is loading, please wait...",
                  //         backgroundColor: Colors.orange,
                  //         colorText: Colors.white,
                  //       );
                  //       return;
                  //     }
                  //
                  //     Get.dialog(
                  //       SearchableDropDown(
                  //         list: clientController.rmList.toList(),
                  //         onSelect: (selected) {
                  //           setState(() {
                  //             clientController.rmIdSelected.value = selected;
                  //           });
                  //         },
                  //       ),
                  //     );
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 15,
                  //       vertical: 18,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(4),
                  //       color: Colors.white,
                  //       border: Border.all(color: Colors.grey),
                  //     ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Expanded(
                  //           child: Text(
                  //             clientController.rmIdSelected.value,
                  //             overflow: TextOverflow.ellipsis,
                  //           ),
                  //         ),
                  //         const Icon(Icons.arrow_drop_down),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  SizedBox(height: 30),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F63F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: clientController.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ✅ Submit form with validation
  // ✅ Submit form with validation
  void _submitForm() {
    // Validation
    if (clientController.firstName.value.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter first name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (clientController.lastName.value.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter last name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (clientController.email.value.text.trim().isEmpty ||
        !clientController.email.value.text.contains('@')) {
      Get.snackbar(
        "Error",
        "Please enter valid email",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (clientController.phoneNumber.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter phone number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (clientController.countryCode.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select country code",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (clientController.universityName.value.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter university name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // if (clientController.rmIdSelected.value == "Select RM ID") {
    //   Get.snackbar(
    //     "Error",
    //     "Please select RM ID",
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return;
    // }

    // ✅ Call API to insert client
    clientController.insertClient();
  }

  TextStyle _labelStyle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
}
