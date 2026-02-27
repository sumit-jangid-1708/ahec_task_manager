import 'package:ahec_task_manager/view/orders/create_order_form.dart';
import 'package:ahec_task_manager/view_models/controller/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../res/components/widgets/search_bar.dart';
import '../../view_models/controller/order_controller.dart';

class OrderScreen extends StatelessWidget {
  final OrderController orderController = Get.put(OrderController());
  final SearchBarController searchController = Get.put(SearchBarController());
  final ScrollController scrollController = ScrollController();

  OrderScreen({super.key}) {
    // Scroll listener for pagination
    scrollController.addListener(() {
      // Only load more when not searching
      if (!orderController.isSearching.value &&
          scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        orderController.loadMoreOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF3F63F4),
          elevation: 0,
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          //   onPressed: () {
          //     Get.back();
          //   },
          // ),
          // ✅ Updated AppBar title with search support
          title: Obx(() => Text(
            orderController.isSearching.value
                ? "Search Results (${orderController.filteredOrders.length})"
                : "Orders (${orderController.totalOrders.value})",
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Get.to(CreateOrderForm());
                },
                icon: const Icon(Icons.add, size: 22, color: Colors.white),
                label: const Text(
                  "Create",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Updated AppSearchBar with onSearchChanged callback
            AppSearchBar(
              controller: searchController,
              hint: "Search orders...",
              onSearchChanged: (query) {
                orderController.searchOrders(query);
              },
            ),
            SizedBox(height: 25),

            Expanded(
              child: Obx(() {
                // Initial loading state
                if (orderController.isLoading.value &&
                    orderController.orders.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                // Get display list (filtered or all)
                final displayList = orderController.displayOrders;

                // ✅ Updated empty state with search support
                if (displayList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          orderController.isSearching.value
                              ? Icons.search_off
                              : Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          orderController.isSearching.value
                              ? 'No orders found for "${searchController.searchText.value}"'
                              : 'No orders found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        if (!orderController.isSearching.value)
                          ElevatedButton.icon(
                            onPressed: () => orderController.refreshOrders(),
                            icon: Icon(Icons.refresh),
                            label: Text('Refresh'),
                          ),
                      ],
                    ),
                  );
                }

                // Order list with responsive layout
                return RefreshIndicator(
                  onRefresh: orderController.refreshOrders,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // MOBILE VIEW
                      if (constraints.maxWidth < 700) {
                        return _mobileList();
                      }

                      // DESKTOP/TABLET VIEW
                      return _desktopTable();
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- MOBILE LIST VIEW ----------------------
  Widget _mobileList() {
    return ListView.builder(
      controller: scrollController,
      // ✅ Updated itemCount to use displayOrders
      itemCount: orderController.displayOrders.length + 1, // +1 for loading indicator
      itemBuilder: (_, index) {
        // Loading indicator at bottom
        if (index == orderController.displayOrders.length) {
          return _buildLoadingIndicator();
        }

        // ✅ Using displayOrders instead of orders
        final order = orderController.displayOrders[index];

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order ID: ${order.orderNumber}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text("Date: ${order.orderDate}"),
                Text("Client: ${order.clientName}"),
                Text("Service: ${order.servicesName}"),
                Text("Deadline: ${order.deadline}"),
                const SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.paymentType == "Full payment"
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.paymentType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: order.paymentType == "Full payment"
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (order.screenshot != null &&
                        order.screenshot!.isNotEmpty)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff3e69c9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _viewScreenshot(order.screenshot!);
                        },
                        child: const Text(
                          "View Screenshot",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    else
                      Text(
                        "No Screenshot",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _actionMenu(order),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------- DESKTOP/TABLET TABLE ----------------------
  Widget _desktopTable() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStatePropertyAll(Colors.grey.shade200),
              columns: const [
                DataColumn(label: Text("#")),
                DataColumn(label: Text("Order ID")),
                DataColumn(label: Text("Order Date")),
                DataColumn(label: Text("Client Name")),
                DataColumn(label: Text("Service")),
                DataColumn(label: Text("Deadline")),
                DataColumn(label: Text("Payment Type")),
                DataColumn(label: Text("Screenshot")),
                DataColumn(label: Text("Action")),
              ],
              // ✅ Updated rows to use displayOrders
              rows: orderController.displayOrders
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                var order = entry.value;

                return DataRow(
                  cells: [
                    DataCell(Text("${index + 1}")),
                    DataCell(Text(order.orderNumber)),
                    DataCell(Text(order.orderDate)),
                    DataCell(Text(order.clientName)),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          order.servicesName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(order.deadline)),
                    DataCell(
                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: order.paymentType == "Full payment"
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.paymentType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: order.paymentType == "Full payment"
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      order.screenshot != null && order.screenshot!.isNotEmpty
                          ? TextButton(
                        onPressed: () =>
                            _viewScreenshot(order.screenshot!),
                        child: const Text("View Screenshot"),
                      )
                          : Text(
                        "No Screenshot",
                        style:
                        TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    DataCell(_actionMenu(order)),
                  ],
                );
              }).toList(),
            ),
          ),
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  // ---------------------- LOADING INDICATOR ----------------------
  // ✅ Updated to hide loading indicator when searching
  Widget _buildLoadingIndicator() {
    return Obx(() {
      // Don't show loading indicator when searching
      if (orderController.isSearching.value) {
        return SizedBox.shrink();
      }

      if (orderController.isLoadingMore.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (!orderController.hasMoreData.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No more orders',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        );
      }
      return SizedBox.shrink();
    });
  }

  // ---------------------- VIEW SCREENSHOT ----------------------
  void _viewScreenshot(String url) {
    Get.dialog(
      Dialog(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
            maxWidth: Get.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Screenshot",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () =>  Navigator.of(Get.context!).pop(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                SizedBox(
                  height: Get.height * 0.5,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          SizedBox(height: 8),
                          Text("Failed to load image"),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text("Close"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------- POPUP MENU ----------------------
  Widget _actionMenu(order) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case "edit":
            print("Edit order: ${order.orderNumber}");
            break;
          case "update_status":
            print("Update status for: ${order.orderNumber}");
            break;
          case "copy_order":
            print("Copy order: ${order.orderNumber}");
            break;
          case "track_status":
            print("Track status for: ${order.orderNumber}");
            break;
          case "client_upload":
            print("Client upload for: ${order.orderNumber}");
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: "edit", child: Text("Edit")),
        PopupMenuItem(value: "update_status", child: Text("Update Status")),
        PopupMenuItem(value: "copy_order", child: Text("Copy Order")),
        PopupMenuItem(value: "track_status", child: Text("Track Status")),
        PopupMenuItem(
            value: "client_upload", child: Text("Client work upload")),
      ],
      child: const Icon(Icons.more_vert),
    );
  }
}