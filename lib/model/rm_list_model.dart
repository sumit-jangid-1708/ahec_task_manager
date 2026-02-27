class RmIDListModel {
  final int status;
  final List<RmIDItem> rmidList;

  RmIDListModel({
    required this.status,
    required this.rmidList,
  });

  factory RmIDListModel.fromJson(Map<String, dynamic> json) {
    return RmIDListModel(
      status: json['status'] ?? 0,
      rmidList: (json['rmidlist'] as List<dynamic>? ?? [])
          .map((e) => RmIDItem.fromJson(e))
          .toList(),
    );
  }
}


class RmIDItem {
  final int id;
  final String rmid;
  final String name;
  final String email;

  RmIDItem({
    required this.id,
    required this.rmid,
    required this.name,
    required this.email,
  });

  factory RmIDItem.fromJson(Map<String, dynamic> json) {
    return RmIDItem(
      id: json['id'] ?? 0,
      rmid: json['rmid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}







// class RmIDListModel {
//   final int status;
//   final List<RmIDItem> rmidList;
//
//   RmIDListModel({
//     required this.status,
//     required this.rmidList,
//   });
//
//   factory RmIDListModel.fromJson(Map<String, dynamic> json) {
//     final raw = json['rmidlist'] as Map?;
//
//     List<RmIDItem> parsed = [];
//
//     if (raw != null) {
//       parsed = raw.entries.map((e) {
//         return RmIDItem(
//           id: int.tryParse(e.key) ?? 0,
//           rmid: e.value ?? '',
//         );
//       }).toList();
//     }
//
//     return RmIDListModel(
//       status: json['status'] ?? 0,
//       rmidList: parsed,
//     );
//   }
// }
//
// class RmIDItem {
//   final int id;
//   final String rmid;
//
//   RmIDItem({
//     required this.id,
//     required this.rmid,
//   });
// }
