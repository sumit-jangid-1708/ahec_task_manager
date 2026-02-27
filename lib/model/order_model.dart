class OrderModel {
  final int status;
  final OrdersListModel usersList;

  OrderModel({
    required this.status,
    required this.usersList,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      status: json['status'] ?? 0,
      usersList: OrdersListModel.fromJson(json['usersList'] ?? {}),
    );
  }
}

class OrdersListModel {
  final int currentPage;
  final List<OrderData> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final String nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  OrdersListModel({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory OrdersListModel.fromJson(Map<String, dynamic> json) {
    List<OrderData> orderList = [];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        orderList.add(OrderData.fromJson(v));
      });
    }

    return OrdersListModel(
      currentPage: json['current_page'] ?? 1,
      data: orderList,
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      nextPageUrl: json['next_page_url'] ?? '',
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 20,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class OrderData {
  final int enId;
  final String orderNumber;
  final String orderDate;
  final String clientName;
  final String servicesName;
  final String tranxid;
  final String writerId;
  final String paymentType;
  final String clientsLastStatus;
  final String deadline;
  final String? screenshot;

  OrderData({
    required this.enId,
    required this.orderNumber,
    required this.orderDate,
    required this.clientName,
    required this.servicesName,
    required this.tranxid,
    required this.writerId,
    required this.paymentType,
    required this.clientsLastStatus,
    required this.deadline,
    this.screenshot,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      enId: json['en_id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      orderDate: json['order_date'] ?? '',
      clientName: json['client_name'] ?? '',
      servicesName: json['services_name'] ?? '',
      tranxid: json['tranxid'] ?? '',
      writerId: json['writer_id'] ?? '0',
      paymentType: json['payment_type'] ?? '',
      clientsLastStatus: json['clients_last_status'] ?? '',
      deadline: json['deadline'] ?? '',
      screenshot: json['Screenshot'],
    );
  }
}