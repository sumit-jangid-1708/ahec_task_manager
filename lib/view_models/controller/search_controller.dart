import 'package:get/get.dart';

class SearchBarController extends GetxController {
  var searchText = ''.obs;

  void onSearchChanged(String query) {
    searchText.value = query;
  }

  void clearSearch() {
    searchText.value = '';
  }
}