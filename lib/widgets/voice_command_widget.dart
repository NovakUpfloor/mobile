// Penjelasan:
// Widget Floating Action Button (FAB) yang reusable untuk fitur perintah suara.
// - Memerlukan `contextName` untuk memberitahu backend halaman mana yang aktif.
// - Memeriksa status login sebelum memulai.
// - Menampilkan bottom sheet saat proses mendengarkan.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:waisaka_property/core/di/service_locator.dart';
import 'package:waisaka_property/features/auth/data/repositories/auth_repository.dart';
import 'package:waisaka_property/features/gemini/data/models/gemini_action_response.dart';
import 'package:waisaka_property/features/gemini/data/repositories/gemini_repository.dart';

class VoiceCommandWidget extends StatefulWidget {
 final String contextName;
 final Map<String, dynamic>? additionalData;
 final Function(GeminiActionResponse) onActionReceived;

 const VoiceCommandWidget({
   super.key,
   required this.contextName,
   this.additionalData,
   required this.onActionReceived,
 });

 @override
 State<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget> {
 final SpeechToText _speechToText = SpeechToText();
 final GeminiRepository _geminiRepository = sl<GeminiRepository>();
 final AuthRepository _authRepository = sl<AuthRepository>();
 bool _isListening = false;

 @override
 void initState() {
   super.initState();
   _speechToText.initialize();
 }

 void _startVoiceCommand() async {
   final token = await _authRepository.getToken();
   if (token == null) {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("Anda harus login untuk menggunakan fitur ini.")),
     );
     // Arahkan ke halaman login
     if (mounted) context.go('/login');
     return;
   }

   setState(() => _isListening = true);

   showModalBottomSheet(
     context: context,
     builder: (ctx) => _buildListeningSheet(),
   ).whenComplete(() => setState(() => _isListening = false));

   _speechToText.listen(
     onResult: (result) {
       if (result.finalResult && result.recognizedWords.isNotEmpty) {
         _processCommand(result.recognizedWords);
       }
     },
     localeId: "id_ID",
   );
 }

 void _processCommand(String command) async {
   try {
     final response = await _geminiRepository.processCommand(
       text: command,
       context: widget.contextName,
       data: widget.additionalData,
     );
     if (mounted) {
       Navigator.of(context).pop(); // Tutup bottom sheet
       widget.onActionReceived(response);
     }
   } catch (e) {
     if (mounted) {
       Navigator.of(context).pop(); // Tutup bottom sheet
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
     }
   }
 }

 Widget _buildListeningSheet() {
   return Container(
     height: 200,
     padding: const EdgeInsets.all(20),
     child: const Center(
       child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text("Mendengarkan...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
           SizedBox(height: 20),
           CircularProgressIndicator(),
         ],
       ),
     ),
   );
 }

 @override
 Widget build(BuildContext context) {
   return FloatingActionButton(
     onPressed: _isListening ? null : _startVoiceCommand,
     tooltip: 'Perintah Suara',
     backgroundColor: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
     child: Icon(_isListening ? Icons.mic_off : Icons.mic),
   );
 }
}