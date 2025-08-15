part of 'gemini_bloc.dart';

abstract class GeminiEvent extends Equatable {
 const GeminiEvent();

 @override
 List<Object?> get props => [];
}

class SendCommandToGemini extends GeminiEvent {
 final String command;
 final String context;
 final Map<String, dynamic>? data;

 const SendCommandToGemini({required this.command, required this.context, this.data});

 @override
 List<Object?> get props => [command, context, data];
}