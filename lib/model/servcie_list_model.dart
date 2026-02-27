class ServiceListModel {
  final int status;
  final Map<String, String> serviceList;

  ServiceListModel({
    required this.status,
    required this.serviceList,
  });

  factory ServiceListModel.fromJson(Map<String, dynamic> json) {
    return ServiceListModel(
      status: json['status'] ?? 0,
      serviceList: (json['serviceList'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key.toString(), value.toString()))
          ?? {},
    );
  }
}
