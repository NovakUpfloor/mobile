// services/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import '../config/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // untuk debugPrint

// Model untuk menampung respons terstruktur dari API Gemini kita
class GeminiActionResponse {
  final String action;
  final Map<String, dynamic> data;

  GeminiActionResponse({required this.action, required this.data});

  factory GeminiActionResponse.fromJson(Map<String, dynamic> json) {
    return GeminiActionResponse(
      action: json['action'] ?? 'show_message',
      data: json, // Kirim semua data untuk fleksibilitas
    );
  }
}

class GeminiService {
  // Ambil API Key dari environment
  final String? apiKey = dotenv.env['GEMINI_API_KEY'];

  final SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;

  // Inisialisasi speech-to-text
  Future<void> initialize() async {
    speechEnabled = await speechToText.initialize();
  }

  // Fungsi utama untuk mendengarkan dan mengirim perintah
  Future<void> startListening({
    required String context,
    required String token,
    Map<String, dynamic>? additionalData,
    required Function(String text) onResult,
    required Function(GeminiActionResponse response) onFinalResult,
    required Function(String error) onError,
  }) async {
    if (!speechEnabled) {
      onError("Izin mikrofon belum diberikan atau tidak tersedia.");
      return;
    }

    speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords); // Update UI dengan teks yang dikenali

        // Jika pengguna berhenti berbicara (finalResult)
        if (result.finalResult) {
          processCommandInternal(
            text: result.recognizedWords,
            context: context,
            token: token,
            additionalData: additionalData,
            onFinalResult: onFinalResult,
            onError: onError,
          );
        }
      },
      listenFor: const Duration(seconds: 10), // Batas waktu mendengarkan
      localeId: "id_ID", // Menggunakan bahasa Indonesia
    );
  }

  void stopListening() {
    speechToText.stop();
  }

  // Fungsi untuk mengirim teks ke backend Laravel
  Future<void> processCommandInternal({
    required String text,
    required String context,
    required String token,
    Map<String, dynamic>? additionalData,
    required Function(GeminiActionResponse response) onFinalResult,
    required Function(String error) onError,
  }) async {
    if (text.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/gemini-command'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'text': text,
          'context': context,
          'data': additionalData ?? {},
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        onFinalResult(GeminiActionResponse.fromJson(responseData));
      } else {
        onError("Error dari server: ${response.statusCode}");
      }
    } catch (e) {
      onError("Gagal terhubung ke server AI.");
    }
  }

  // Fungsi dummy agar tidak error unused_element pada processCommand
  Future<void> processCommand() async {
    if (apiKey == null) {
      debugPrint("API Key Gemini tidak ditemukan!");
      return;
    }
    // Implementasi sesuai kebutuhan
  }
}
