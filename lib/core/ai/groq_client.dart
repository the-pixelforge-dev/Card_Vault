import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown when the Groq API request fails or returns something we can't
/// parse into a usable answer.
class GroqRequestException implements Exception {
  const GroqRequestException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// A deliberately minimal, hand-written REST client for Groq's
/// OpenAI-compatible `chat/completions` endpoint.
///
/// This app sends the user's own API key with every request — never a
/// shared Anthropic/Google/Groq credential — and this is the ONLY network
/// call the app ever makes. Keeping it to a single small file (rather than
/// depending on a heavyweight SDK) makes it trivial to audit exactly what
/// leaves the device.
class GroqClient {
  const GroqClient({this.model = 'openai/gpt-oss-120b'});

  final String model;

  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';

  /// Generates text for [prompt]. When [responseSchema] is given, the model
  /// is instructed (via a system message describing the required JSON
  /// shape, plus `response_format: json_object`) to return JSON matching
  /// that shape, and the returned string is that JSON text rather than
  /// free-form prose.
  ///
  /// Groq's OpenAI-compatible endpoint supports a stricter
  /// `response_format: json_schema` on some models, but `json_object` plus
  /// explicit instructions is universally supported across Groq's models,
  /// so it's the safer default here.
  Future<String> generateText({
    required String apiKey,
    required String prompt,
    Map<String, Object?>? responseSchema,
  }) async {
    final uri = Uri.parse(_endpoint);

    final http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
              // Groq's edge (Cloudflare) blocks requests with no/unusual
              // User-Agent as bot traffic; Dart's http client sends none
              // by default, so this header is required for requests to
              // reach Groq at all.
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              if (responseSchema != null)
                'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(minutes: 1, seconds: 30));
    } on TimeoutException {
      throw const GroqRequestException(
        'Groq took too long to respond. Please try again.',
      );
    } catch (_) {
      throw const GroqRequestException(
        "Couldn't reach Groq — check your internet connection and try "
        'again.',
      );
    }

    if (response.statusCode != 200) {
      throw GroqRequestException(_messageForStatus(response.statusCode));
    }

    final decoded = jsonDecode(response.body) as Map<String, Object?>;
    final choices = decoded['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      throw const GroqRequestException(
        "Groq didn't return an answer for this request. Try rephrasing "
        'your question.',
      );
    }

    final choice = choices.first as Map<String, Object?>;
    final message = choice['message'] as Map<String, Object?>?;
    final text = message?['content'] as String?;

    if (text == null || text.isEmpty) {
      throw const GroqRequestException(
        "Groq didn't return an answer for this request. Try rephrasing "
        'your question.',
      );
    }
    return text;
  }

  String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 429:
        return 'Card Sense is being rate-limited by Groq right now. '
            'Please wait a moment and try again.';
      case 401:
      case 403:
        return 'Groq rejected this request — check that your API key '
            'in Settings → Card Sense is still valid.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Groq is temporarily overloaded. Please wait a moment and '
            'try again.';
      default:
        return "Groq couldn't process this request right now "
            '(error $statusCode). Please try again.';
    }
  }
}
