class DashboardDataModel {
  final DashboardData data;
  final int status;

  DashboardDataModel({
    required this.data,
    required this.status,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      data: DashboardData.fromJson(json['data'] ?? {}),
      status: json['status'] ?? 0,
    );
  }
}

class DashboardData {
  final CurrencyAmount weekTotalAmount;
  final CurrencyAmount monthTotalCurrencyAmount;

  DashboardData({
    required this.weekTotalAmount,
    required this.monthTotalCurrencyAmount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      weekTotalAmount:
      CurrencyAmount.fromJson(json['weekTotalAmount'] ?? {}),
      monthTotalCurrencyAmount:
      CurrencyAmount.fromJson(json['mothTotalCurrencyAmount'] ?? {}),
    );
  }
}

class CurrencyAmount {
  final String inr;
  final String aud;

  CurrencyAmount({
    required this.inr,
    required this.aud,
  });

  factory CurrencyAmount.fromJson(Map<String, dynamic> json) {
    return CurrencyAmount(
      inr: json['inr']?.toString() ?? "0.00",
      aud: json['aud']?.toString() ?? "0.00",
    );
  }
}