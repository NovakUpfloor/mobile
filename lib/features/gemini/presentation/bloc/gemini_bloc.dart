// Penjelasan:
// BLoC untuk mengelola state dari interaksi dengan Gemini.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:waisaka_property/features/gemini/data/models/gemini_action_response.dart';
import 'package:waisaka_property/features/gemini/data/repositories/gemini_repository.dart';

part 'gemini_event.dart';
part 'gemini_state.dart';

class GeminiBloc extends Bloc<GeminiEvent, GeminiState> {
 final GeminiRepository _geminiRepository;

 GeminiBloc({required GeminiRepository geminiRepository})
     : _geminiRepository = geminiRepository,
       super(GeminiInitial()) {
   on<SendCommandToGemini>(_onSendCommand);
 }

 Future<void> _onSendCommand(SendCommandToGemini event, Emitter<GeminiState> emit) async {
   emit(GeminiLoading());
   try {
     final response = await _geminiRepository.processCommand(
       text: event.command,
       context: event.context,
       data: event.data,
     );
     emit(GeminiActionSuccess(response: response));
   } catch (e) {
     emit(GeminiFailure(error: e.toString()));
   }
 }
}