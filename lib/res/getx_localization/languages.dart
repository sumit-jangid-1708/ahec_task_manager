
import 'package:get/get.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'email': "Email",
      'password': "Password",
      'internet_exception':
      "we are unable to show result \nPlease check your internet \nconnection",
      'splash_screen': "Hello \nWelcome to our app",
      'Auth': "Login",
      'home' : "Home Screen",
      'Error': "Something went wrong",
    },
    'hi_IN': {'email_hint': "ईमेल दर्ज करें"},
  };
}