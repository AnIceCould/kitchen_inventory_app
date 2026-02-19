/// API Key Configuration File
/// 
/// Centralized management of all third-party API keys and configurations
class ApiConfig {
  // Edamam API credentials
  // Registration URL: https://developer.edamam.com/
  static const String edamamAppId = '';
  static const String edamamAppKey = '';

  // Spoonacular API credentials
  // Registration URL: https://spoonacular.com/food-api
  static const String spoonacularApiKey = '';

  // Baidu AI credentials
  // Registration URL: https://ai.baidu.com/
  static const String baiduApiKey = '';
  static const String baiduSecretKey = '';

  // Baidu Translation API credentials
  // Registration URL: http://api.fanyi.baidu.com/
  static const String baiduTranslateAppId = '';
  static const String baiduTranslateSecretKey = '';

  // TheMealDB API base URL (public API, no key required)
  static const String mealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1';
}
