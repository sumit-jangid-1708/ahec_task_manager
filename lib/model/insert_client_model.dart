class InsertClientModel {
  final String message;
  final int status;

  InsertClientModel({
    required this.message,
    required this.status,
  });

  factory InsertClientModel.fromJson(Map<String, dynamic> json) {
    return InsertClientModel(
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}
