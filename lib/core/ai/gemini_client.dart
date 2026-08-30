import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when the Gemini API request fails or returns something we can't
/// parse into a usable answer.
class GeminiRequestException implements Exception {
  const GeminiRequestException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// A deliberately minimal, hand-written REST client for Gemini's
/// `generateContent` endpoint.
///
/// This app sends the user's own API key with every request — never a
/// shared Anthropic/Google credential — and this is the ONLY network call
/// the app ever makes. Keeping it to a single small file (rather than
/// depending on a Firebase-coupled or deprecated SDK) makes it trivial to
/// audit exactly what leaves the device.
class GeminiClient {
  const GeminiClient({this.model = 'gemini-2.5-flash'});

  final String model;

  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<String> generateText({
    required String apiKey,
    required String prompt,
  }) async {
    final uri = Uri.parse('$_baseUrl/$model:generateContent?key=$apiKey');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw GeminiRequestException(
        'Gemini request failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, Object?>;
    final candidates = decoded['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw const GeminiRequestException('Gemini returned no candidates.');
    }

    final content = candidates.first as Map<String, Object?>;
    final parts = (content['content'] as Map<String, Object?>?)?['parts']
        as List?;
    final text = parts?.map((p) => (p as Map)['text']).whereType<String>().join();

    if (text == null || text.isEmpty) {
      throw const GeminiRequestException('Gemini returned an empty answer.');
    }
    return text;
  }
}
