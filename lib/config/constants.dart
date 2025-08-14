

// ✅ Ganti IP / domain di sini
const String localIpAddress = "192.168.18.59";

// ✅ Base URL Laravel API
const String apiBaseUrl =
    "${localIpAddress}/novak_upfloor/public_html/api/v1";

// ✅ Base URL untuk gambar properti
const String imageBaseUrl =
    "${localIpAddress}/novak_upfloor/public_html/assets/upload/property/";

// ✅ Contoh endpoint API
class ApiEndpoints {
  static const String properties = "$apiBaseUrl/properties";
  static const String articles = "$apiBaseUrl/articles";
  static const String packages = "$apiBaseUrl/packages";
  static const String login = "$apiBaseUrl/auth/login";
  static const String register = "$apiBaseUrl/auth/register";
  static const String logout = "$apiBaseUrl/auth/logout";
}
