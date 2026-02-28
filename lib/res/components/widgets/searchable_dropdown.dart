import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchableDropDown extends StatefulWidget {
  final List<String> list;
  final Function(String) onSelect;
  final String? title;

  const SearchableDropDown({
    super.key,
    required this.list,
    required this.onSelect,
    this.title,
  });

  @override
  State<SearchableDropDown> createState() => _SearchableDropDownState();
}

class _SearchableDropDownState extends State<SearchableDropDown> {
  late List<String> _filteredList;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredList = List.from(widget.list);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredList = List.from(widget.list);
      } else {
        _filteredList = widget.list
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 400,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF3F63F4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title ?? "Select",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF3F63F4)),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: _filteredList.isEmpty
                  ? const Center(
                child: Text(
                  "No results found",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.separated(
                itemCount: _filteredList.length,
                separatorBuilder: (context, index) {
                  return const Divider(height: 1);
                },
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text(
                      _filteredList[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      widget.onSelect(_filteredList[index]);
                      // Get.back();
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}