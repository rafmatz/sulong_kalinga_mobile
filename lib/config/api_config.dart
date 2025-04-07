class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // For Android emulator to localhost
  // static const String baseUrl = 'http://localhost:8000/api'; // For iOS simulator
  // static const String baseUrl = 'https://your-production-url.com/api'; // Production

  static const int connectTimeout = 15000; // 15 seconds
  static const int receiveTimeout = 15000; // 15 seconds
}