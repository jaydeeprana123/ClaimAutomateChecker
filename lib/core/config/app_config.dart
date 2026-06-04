import '../services/storage_service.dart';

class AppConfig {
  // Replace this placeholder with your actual Gemini API Key
  static const String geminiApiKey = 'AIzaSyAvx8pTT21LKoBCEHIuHS4mwY8XIdecQBo';
  static const String defaultBaseUrl =
      'https://7fba-115-246-26-2.ngrok-free.app';

  static String get baseUrl => StorageService.getBaseUrl() ?? defaultBaseUrl;
}
