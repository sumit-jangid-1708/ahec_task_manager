class DashboardResponseModel {
  final bool status;
  final String message;
  final DashboardFilter filter;
  final DashboardData data;

  DashboardResponseModel({
    required this.status,
    required this.message,
    required this.filter,
    required this.data,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      filter: DashboardFilter.fromJson(json['filter'] ?? {}),
      data: DashboardData.fromJson(json['data'] ?? {}),
    );
  }
}

class DashboardFilter {
  final int year;
  final int rmId;

  DashboardFilter({
    required this.year,
    required this.rmId,
  });

  factory DashboardFilter.fromJson(Map<String, dynamic> json) {
    return DashboardFilter(
      year: json['year'] ?? 0,
      rmId: json['rm_id'] ?? 0,
    );
  }
}

class DashboardData {
  final Summary summary;
  final List<CurrencyWiseAmount> currencyWiseAmount;
  final RmOrderCount rmOrderCount;
  final List<RmMonthlyOrders> rmMonthlyOrders;
  final List<RmMonthlyAud> rmMonthlyAud;
  final MonthlyAudOrders monthlyAudOrders;

  DashboardData({
    required this.summary,
    required this.currencyWiseAmount,
    required this.rmOrderCount,
    required this.rmMonthlyOrders,
    required this.rmMonthlyAud,
    required this.monthlyAudOrders,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      summary: Summary.fromJson(json['summary'] ?? {}),
      currencyWiseAmount: (json['currency_wise_amount'] as List? ?? [])
          .map((e) => CurrencyWiseAmount.fromJson(e))
          .toList(),
      rmOrderCount:
      RmOrderCount.fromJson(json['rm_order_count'] ?? {}),
      rmMonthlyOrders: (json['rm_monthly_orders'] as List? ?? [])
          .map((e) => RmMonthlyOrders.fromJson(e))
          .toList(),
      rmMonthlyAud: (json['rm_monthly_aud'] as List? ?? [])
          .map((e) => RmMonthlyAud.fromJson(e))
          .toList(),
      monthlyAudOrders:
      MonthlyAudOrders.fromJson(json['monthly_aud_orders'] ?? {}),
    );
  }
}


class Summary {
  final String currentMonth;
  final int currentYear;
  final double monthAud;
  final int monthInr;
  final int monthWordCount;
  final double weekAud;
  final int weekInr;
  final int weekWordCount;

  Summary({
    required this.currentMonth,
    required this.currentYear,
    required this.monthAud,
    required this.monthInr,
    required this.monthWordCount,
    required this.weekAud,
    required this.weekInr,
    required this.weekWordCount,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      currentMonth: json['current_month'] ?? '',
      currentYear: json['current_year'] ?? 0,
      monthAud: (json['month_aud'] ?? 0).toDouble(),
      monthInr: json['month_inr'] ?? 0,
      monthWordCount: json['month_word_count'] ?? 0,
      weekAud: (json['week_aud'] ?? 0).toDouble(),
      weekInr: json['week_inr'] ?? 0,
      weekWordCount: json['week_word_count'] ?? 0,
    );
  }
}

class CurrencyWiseAmount {
  final String name;
  final String x;
  final String y;
  final String z;

  CurrencyWiseAmount({
    required this.name,
    required this.x,
    required this.y,
    required this.z,
  });

  factory CurrencyWiseAmount.fromJson(Map<String, dynamic> json) {
    return CurrencyWiseAmount(
      name: json['name'] ?? '',
      x: json['x'] ?? '',
      y: json['y'] ?? '',
      z: json['z'] ?? '',
    );
  }
}

class RmOrderCount {
  final List<RmSeries> series;
  final List<RmDrilldown> drilldown;

  RmOrderCount({
    required this.series,
    required this.drilldown,
  });

  factory RmOrderCount.fromJson(Map<String, dynamic> json) {
    return RmOrderCount(
      series: (json['series'] as List? ?? [])
          .map((e) => RmSeries.fromJson(e))
          .toList(),
      drilldown: (json['drilldown'] as List? ?? [])
          .map((e) => RmDrilldown.fromJson(e))
          .toList(),
    );
  }
}

class RmSeries {
  final String name;
  final int y;
  final String drilldown;

  RmSeries({
    required this.name,
    required this.y,
    required this.drilldown,
  });

  factory RmSeries.fromJson(Map<String, dynamic> json) {
    return RmSeries(
      name: json['name'] ?? '',
      y: json['y'] ?? 0,
      drilldown: json['drilldown'] ?? '',
    );
  }
}

class RmDrilldown {
  final String name;
  final String id;
  final List<List<dynamic>> data;

  RmDrilldown({
    required this.name,
    required this.id,
    required this.data,
  });

  factory RmDrilldown.fromJson(Map<String, dynamic> json) {
    return RmDrilldown(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => List<dynamic>.from(e))
          .toList(),
    );
  }
}

class RmMonthlyOrders {
  final String name;
  final List<int> data;

  RmMonthlyOrders({
    required this.name,
    required this.data,
  });

  factory RmMonthlyOrders.fromJson(Map<String, dynamic> json) {
    return RmMonthlyOrders(
      name: json['name'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => e as int)
          .toList(),
    );
  }
}

class RmMonthlyAud {
  final String name;
  final List<double> data;

  RmMonthlyAud({
    required this.name,
    required this.data,
  });

  factory RmMonthlyAud.fromJson(Map<String, dynamic> json) {
    return RmMonthlyAud(
      name: json['name'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map<double>((e) => (e as num?)?.toDouble() ?? 0.0)
          .toList(),
    );
  }
}

class MonthlyAudOrders {
  final List<String> monthNames;
  final List<double> audAmounts;
  final List<int> orderCounts;

  MonthlyAudOrders({
    required this.monthNames,
    required this.audAmounts,
    required this.orderCounts,
  });

  factory MonthlyAudOrders.fromJson(Map<String, dynamic> json) {
    return MonthlyAudOrders(
      monthNames: (json['month_names'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),

      audAmounts: (json['aud_amounts'] as List<dynamic>? ?? [])
          .map<double>((e) => (e as num?)?.toDouble() ?? 0.0)
          .toList(),

      orderCounts: (json['order_counts'] as List<dynamic>? ?? [])
          .map<int>((e) => (e as num?)?.toInt() ?? 0)
          .toList(),
    );
  }
}