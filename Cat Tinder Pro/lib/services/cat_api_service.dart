import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cat.dart';

class CatApiService {
  static const String _apiUrl =
      'https://api.thecatapi.com/v1/images/search?has_breeds=1';
  static const String _apiKey =
      'live_3VnUjjUpUupYRl3LtsP4lM54vrINMngwnRv7xO95BqYnsZdTuOTWLb6m91cBWM6I';

  Future<Cat> fetchRandomCat() async {
    while (true) {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'x-api-key': _apiKey},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          final cat = Cat.fromJson(data[0] as Map<String, dynamic>);
          if (cat.description.isNotEmpty) {
            return cat;
          }
        } else {
          throw Exception('No cat data received');
        }
      } else {
        throw Exception('Failed to load cat: ${response.statusCode}');
      }
    }
  }
}
