import 'dart:ui';

import 'package:flutter/material.dart';

class ClientModel {
  final int status;
  final UsersListModel usersList;

  ClientModel({
    required this.status,
    required this.usersList,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      status: json['status'] ?? 0,
      usersList: UsersListModel.fromJson(json['usersList'] ?? {}),
    );
  }
}

class UsersListModel {
  final int currentPage;
  final List<ClientData> data;
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

  UsersListModel({
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

  factory UsersListModel.fromJson(Map<String, dynamic> json) {
    List<ClientData> clientList = [];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        clientList.add(ClientData.fromJson(v));
      });
    }

    return UsersListModel(
      currentPage: json['current_page'] ?? 1,
      data: clientList,
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

class ClientData {
  final int userId;
  final String userName;
  final String? profile;
  final String userEmail;
  final String userPassword;
  final String userStatus;
  final String userCreatedAt;
  final String rmId;
  final String mobile;
  final String phoneCode;
  final String univercityName;
  final String? tokenId;
  final String isMultipal;
  final String? isApproved;
  final String? rmIdsList;
  final String chnagePasswordCount;
  final String? otp;
  final String rmUserName;
  final List<RmUsers> rmusers;

  ClientData({
    required this.userId,
    required this.userName,
    this.profile,
    required this.userEmail,
    required this.userPassword,
    required this.userStatus,
    required this.userCreatedAt,
    required this.rmId,
    required this.mobile,
    required this.phoneCode,
    required this.univercityName,
    this.tokenId,
    required this.isMultipal,
    this.isApproved,
    this.rmIdsList,
    required this.chnagePasswordCount,
    this.otp,
    required this.rmUserName,
    required this.rmusers,
  });

  factory ClientData.fromJson(Map<String, dynamic> json) {
    List<RmUsers> rmUsersList = [];
    if (json['rmusers'] != null) {
      json['rmusers'].forEach((v) {
        rmUsersList.add(RmUsers.fromJson(v));
      });
    }

    return ClientData(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      profile: json['profile'],
      userEmail: json['user_email'] ?? '',
      userPassword: json['user_password'] ?? '',
      userStatus: json['user_status'] ?? '',
      userCreatedAt: json['user_created_at'] ?? '',
      rmId: json['rm_id'] ?? '',
      mobile: json['mobile'] ?? '',
      phoneCode: json['phone_code'] ?? '',
      univercityName: json['univercity_name'] ?? '',
      tokenId: json['_token_id'],
      isMultipal: json['is_multipal'] ?? '0',
      isApproved: json['is_approved'],
      rmIdsList: json['rm_ids_list'],
      chnagePasswordCount: json['chnage_password_count'] ?? '0',
      otp: json['otp'],
      rmUserName: json['rm_user_name'] ?? '',
      rmusers: rmUsersList,
    );
  }
}

class RmUsers {
  final String id;
  final String name;
  final String status;
  final String email;
  final String phone;
  final String createdAt;
  final String updatedAt;
  final String rmid;
  final String symbol;
  final String emid;
  final String empType;

  RmUsers({
    required this.id,
    required this.name,
    required this.status,
    required this.email,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.rmid,
    required this.symbol,
    required this.emid,
    required this.empType,
  });

  factory RmUsers.fromJson(Map<String, dynamic> json) {
    return RmUsers(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      rmid: json['rmid'] ?? '',
      symbol: json['symbol'] ?? '',
      emid: json['emid'] ?? '',
      empType: json['emp_type'] ?? '',
    );
  }
}


extension ClientStatus on ClientData {

  String get statusText {
    if (isMultipal == "0") return "Auto-Approved";

    if (isMultipal == "1") {
      switch (isApproved) {
        case "0":
          return "Pending";
        case "1":
          return "Admin-Approved";
        case "2":
          return "Admin-Rejected";
        default:
          return "Unknown";
      }
    }

    return "Unknown";
  }

  Color get statusColor {
    if (isMultipal == "0") return Colors.green;

    if (isMultipal == "1") {
      switch (isApproved) {
        case "0":
          return Colors.orange;
        case "1":
          return Colors.blue;
        case "2":
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Colors.grey;
  }
}