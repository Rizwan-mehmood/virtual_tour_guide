import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent';
  static const String _apiKey = 'AIzaSyCpaJrrf8Lc1k-6weokFkpPqHTvdIADV2g';

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": _buildPrompt(message)},
              ],
            },
          ],
          "safetySettings": [
            {
              "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
              "threshold": "BLOCK_ONLY_HIGH",
            },
            {
              "category": "HARM_CATEGORY_HARASSMENT",
              "threshold": "BLOCK_ONLY_HIGH",
            },
            {
              "category": "HARM_CATEGORY_HATE_SPEECH",
              "threshold": "BLOCK_ONLY_HIGH",
            },
            {
              "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
              "threshold": "BLOCK_ONLY_HIGH",
            },
          ],
          "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 800,
            "topP": 0.8,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'].trim();
      } else {
        throw Exception('API Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static String _buildPrompt(String message) {
    return '''You are a knowledgeable museum guide for the Louvre Abu Dhabi museum. 
[Your existing prompt here...]
Current query: $message''';
  }
}
