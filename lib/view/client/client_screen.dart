import 'package:ahec_task_manager/model/client_model.dart';
import 'package:ahec_task_manager/view/client/add_client_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/components/widgets/client_card.dart';
import '../../res/components/widgets/search_bar.dart';
import '../../view_models/controller/client_controller.dart';
import '../../view_models/controller/search_controller.dart';

class ClientScreen extends StatelessWidget {
  // ClientScreen({super.key});

  final ClientController clientController = Get.put(ClientController());
  final SearchBarController searchController = Get.put(SearchBarController());
  final ScrollController scrollController = ScrollController();

  ClientScreen({super.key}) {
    scrollController.addListener(() {
      // Only load more when not searching
      if (!clientController.isSearching.value &&
          scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        clientController.loadMoreClients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF3F63F4),
          elevation: 0,
          // leading: IconButton(
          //   icon:  Icon(Icons.arrow_back, color: Colors.white, size: 28),
          //   onPressed: () => Get.back(),
          // ),
          title: Obx(() => Text(
            clientController.isSearching.value
                ? "Search Results (${clientController.filteredClients.length})"
                : "Clients (${clientController.totalClients.value})",
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton.icon(
                onPressed: () {
                  Get.to(AddClientForm());
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 22),
                label: const Text(
                  "Create",
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
            AppSearchBar(
              controller: searchController,
              hint: "Search clients...",
              onSearchChanged: (query) {
                clientController.searchClients(query);
              },
            ),
            SizedBox(height: 25),

            Expanded(
              child: Obx(() {
                // Initial loading state
                if (clientController.isLoading.value && clientController.clients.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                // Get display list (filtered or all)
                final displayList = clientController.displayClients;

                // Empty state
                if (displayList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          clientController.isSearching.value
                              ? Icons.search_off
                              : Icons.person_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          clientController.isSearching.value
                              ? 'No clients found for "${searchController.searchText.value}"'
                              : 'No clients found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        if (!clientController.isSearching.value)
                          ElevatedButton.icon(
                            onPressed: () => clientController.refreshClients(),
                            icon: Icon(Icons.refresh),
                            label: Text('Refresh'),
                          ),
                      ],
                    ),
                  );
                }

                // Client list with responsive layout
                return RefreshIndicator(
                  onRefresh: clientController.refreshClients,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // ---- MOBILE ----
                      if (constraints.maxWidth < 600) {
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: displayList.length + 1,
                          itemBuilder: (_, index) {
                            if (index == displayList.length) {
                              return _buildLoadingIndicator();
                            }

                            final client = displayList[index];
                            return ClientCard(
                              number: "#${client.userId}",
                              name: client.userName,
                              date: _formatDate(client.userCreatedAt),
                              email: client.userEmail,
                              mobile: client.mobile,
                              status: client.statusText,
                              statusColor: client.statusColor,
                              university: client.univercityName,
                              onEdit: () {
                                print('Edit client: ${client.userName}');
                              },
                            );
                          },
                        );
                      }

                      // ---- TABLET ----
                      if (constraints.maxWidth < 1000) {
                        return GridView.builder(
                          controller: scrollController,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.9,
                          ),
                          itemCount: displayList.length + 1,
                          itemBuilder: (_, index) {
                            if (index == displayList.length) {
                              return _buildLoadingIndicator();
                            }

                            final client = displayList[index];
                            return ClientCard(
                              number: "#${client.userId}",
                              name: client.userName,
                              date: _formatDate(client.userCreatedAt),
                              email: client.userEmail,
                              mobile: client.mobile,
                              status: client.statusText,
                              statusColor: client.statusColor,
                              university: client.univercityName,
                              onEdit: () {
                                print('Edit client: ${client.userName}');
                              },
                            );
                          },
                        );
                      }

                      // ---- DESKTOP ----
                      return GridView.builder(
                        controller: scrollController,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: 2.0,
                        ),
                        itemCount: displayList.length + 1,
                        itemBuilder: (_, index) {
                          if (index == displayList.length) {
                            return _buildLoadingIndicator();
                          }

                          final client = displayList[index];
                          return ClientCard(
                            number: "#${client.userId}",
                            name: client.userName,
                            date: _formatDate(client.userCreatedAt),
                            email: client.userEmail,
                            mobile: client.mobile,
                            status: client.statusText,
                            statusColor: client.statusColor,
                            university: client.univercityName,
                            onEdit: () {
                              print('Edit client: ${client.userName}');
                            },
                          );
                        },
                      );
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

  Widget _buildLoadingIndicator() {
    return Obx(() {
      // Don't show loading indicator when searching
      if (clientController.isSearching.value) {
        return SizedBox.shrink();
      }

      if (clientController.isLoadingMore.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        );
      } else if (!clientController.hasMoreData.value) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No more clients',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        );
      }
      return SizedBox.shrink();
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  // String _getStatus(String statusCode) {
  //   switch (statusCode) {
  //     case "1":
  //       return "Active";
  //     case "2":
  //       return "Pending";
  //     case "0":
  //       return "Inactive";
  //     default:
  //       return "Unknown";
  //   }
  // }
}