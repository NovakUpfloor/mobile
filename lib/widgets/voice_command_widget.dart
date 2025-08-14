// lib/widgets/voice_command_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../providers/auth_provider.dart';

class VoiceCommandWidget extends StatefulWidget {
  final String context;
  final Map<String, dynamic>? additionalData;
  final Function(GeminiActionResponse response) onActionReceived;

  const VoiceCommandWidget({
    super.key,
    required this.context,
    required this.onActionReceived,
    this.additionalData,
  });

  @override
  State<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends State<VoiceCommandWidget> {
  final GeminiService _geminiService = GeminiService();
  String _statusText = "Tekan tombol dan mulai berbicara...";
  String _recognizedText = "";
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _geminiService.initialize();
  }

  void _startVoiceCommand() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan login untuk menggunakan fitur ini.")));
      return;
    }
    setState(() {
      _isListening = true;
      _statusText = "Mendengarkan...";
      _recognizedText = "";
    });
    _geminiService.startListening(
      context: widget.context,
      token: token,
      additionalData: widget.additionalData,
      onResult: (text) => setState(() => _recognizedText = text),
      onFinalResult: (response) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _statusText = "Tekan tombol dan mulai berbicara...";
        });
        Navigator.of(context).pop();
        widget.onActionReceived(response);
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _statusText = "Terjadi kesalahan. Coba lagi.";
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      },
    );
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            if (_isListening) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if(mounted) setModalState(() {});
              });
            }
            return Container(
              padding: const EdgeInsets.all(24),
              height: 220,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_statusText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _recognizedText.isEmpty ? '"Contoh: Cari rumah di Surabaya"' : _recognizedText,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: _recognizedText.isEmpty ? FontStyle.italic : FontStyle.normal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isListening) const CircularProgressIndicator(),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (_isListening) {
        _geminiService.stopListening();
        setState(() {
          _isListening = false;
          _statusText = "Tekan tombol dan mulai berbicara...";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _isListening ? null : _startVoiceCommand,
      tooltip: 'Perintah Suara',
      backgroundColor: _isListening ? Colors.red : Theme.of(context).floatingActionButtonTheme.backgroundColor,
      child: Icon(_isListening ? Icons.mic : Icons.mic_none),
    );
  }
}
