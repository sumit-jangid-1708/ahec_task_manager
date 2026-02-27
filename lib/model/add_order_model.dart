class AddOrderModel {
  final String message;
  final int status;

  AddOrderModel({
    required this.message,
    required this.status,
  });

  factory AddOrderModel.fromJson(Map<String, dynamic> json) {
    return AddOrderModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}
