class CurrencyModel {
  int? status;
  List<CurrencyItem>? currencyList;

  CurrencyModel({this.status, this.currencyList});

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['currencyList'] != null) {
      currencyList = <CurrencyItem>[];
      json['currencyList'].forEach((v) {
        currencyList!.add(CurrencyItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    if (currencyList != null) {
      data['currencyList'] = currencyList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CurrencyItem {
  int? currencyId;
  String? currencyName;
  String? currencyCode;
  String? currencySymbol;

  CurrencyItem({
    this.currencyId,
    this.currencyName,
    this.currencyCode,
    this.currencySymbol,
  });

  CurrencyItem.fromJson(Map<String, dynamic> json) {
    currencyId = json['currency_id'];
    currencyName = json['currency_name'];
    currencyCode = json['currency_code'];
    currencySymbol = json['currency_symbol'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['currency_id'] = currencyId;
    data['currency_name'] = currencyName;
    data['currency_code'] = currencyCode;
    data['currency_symbol'] = currencySymbol;
    return data;
  }
}
