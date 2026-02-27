class LoginResponseModel {
  final int status;
  final String message;
  final UserModel user;

  LoginResponseModel({
    required this.status,
    required this.message,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

class UserModel {
  final String teamId;
  final String teamName;
  final String teamStatus;
  final String teamEmail;
  final String teamPassword;
  final String teamDob;
  final String? teamDoj;
  final String? teamDol;
  final String teamMob;
  final String teamOfficeMob;
  final String teamAddress;
  final String teamPan;
  final String teamAadhar;
  final String teamType;
  final String teamCreationDate;
  final String teamLastUpdate;
  final String token;

  UserModel({
    required this.teamId,
    required this.teamName,
    required this.teamStatus,
    required this.teamEmail,
    required this.teamPassword,
    required this.teamDob,
    this.teamDoj,
    this.teamDol,
    required this.teamMob,
    required this.teamOfficeMob,
    required this.teamAddress,
    required this.teamPan,
    required this.teamAadhar,
    required this.teamType,
    required this.teamCreationDate,
    required this.teamLastUpdate,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      teamId: json['team_id'] ?? '',
      teamName: json['team_name'] ?? '',
      teamStatus: json['team_status'] ?? '',
      teamEmail: json['team_email'] ?? '',
      teamPassword: json['team_password'] ?? '',
      teamDob: json['team_dob'] ?? '',
      teamDoj: json['team_doj'],
      teamDol: json['team_dol'],
      teamMob: json['team_mob'] ?? '',
      teamOfficeMob: json['team_office_mob'] ?? '',
      teamAddress: json['team_address'] ?? '',
      teamPan: json['team_pan'] ?? '',
      teamAadhar: json['team_addhar'] ?? '',
      teamType: json['team_type'] ?? '',
      teamCreationDate: json['team_creation_date'] ?? '',
      teamLastUpdate: json['team_last_update'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
