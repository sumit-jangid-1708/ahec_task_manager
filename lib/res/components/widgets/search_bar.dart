import 'package:ahec_task_manager/view_models/controller/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSearchBar extends StatelessWidget {
  final String hint;
  final SearchBarController controller;
  final Function(String)? onSearchChanged;

  AppSearchBar({
    super.key,
    this.hint = "Search...",
    required this.controller,
    this.onSearchChanged,
  });

  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: Colors.grey.shade700, size: 22),
          Expanded(
            child: TextField(
              controller: textController,
              onChanged: (value) {
                controller.onSearchChanged(value);
                if (onSearchChanged != null) {
                  onSearchChanged!(value);
                }
              },
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          Obx(() {
            return controller.searchText.value.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                textController.clear();
                controller.clearSearch();
                if (onSearchChanged != null) {
                  onSearchChanged!('');
                }
              },
            )
                : const SizedBox();
          }),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}