class StorageKeys {
  StorageKeys._();

  static const String token = "token";
  static const String isLoggedIn = "isLoggedIn";
  static const String teamName = "teamName";
  static const String teamEmail = "teamEmail";

// Note: rmId is intentionally removed from storage.
// The RM list ID is always derived fresh on each session
// by matching teamName + teamEmail against the RM list API.
// This ensures different users always get their correct RM ID.
}


// class StorageKeys{
//   static const token = "token";
//   static const rmId = "rmId";
//   static const isLoggedIn = "isLoggedIn";
//   static const teamName = "teamName";
//   static const teamEmail = "teamEmail";
// }