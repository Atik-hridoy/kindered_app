abstract class AppUrls {
  static const String baseUrl = 'http://10.10.7.62:7007/api/v1';
  static const String imageUrl = 'http://10.10.7.62:7007';

  // static const String baseUrl = 'https://asif7001.binarybards.online/api/v1';
  // static const String imageUrl = 'https://asif7001.binarybards.online';

  // Auth endpoints

  static const String createAccount = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';



  // accounts setting endpoints
  static const String completeProfile = '/users/complete-profile';
  static const String getProfile = '/users/profile';
  static const String updateProfile = '/users/profile';




  // home
  static const String aiMatchmakingDefault = '/ai-chat/matchmaking';
  static const String aiQuickQuestions = '/ai-chat/quick-questions';
  static const String aiNextMatch = '/ai-chat/actions';
  static const String aiCurrentMatch = '/ai-chat/current-match';


  //location
  static const String userLocation = '/users/update-location';
}