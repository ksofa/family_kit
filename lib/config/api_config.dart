class ApiConfig {
  static const String baseUrl = 'https://us-central1-fluttermet.cloudfunctions.net/api';
  static const int timeout = 30; // seconds
  
  static const String firebaseProjectId = 'fluttermet';
  static const String region = 'us-central1'; // Измените если нужно
  
  static String get functionsBaseUrl => baseUrl;
  
  // Endpoints
  static const String medicinesEndpoint = '/medicines';
  static const String firstAidKitsEndpoint = '/first-aid-kits';
  static const String usersEndpoint = '/users';
} 