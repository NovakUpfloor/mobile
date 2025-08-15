part of 'gemini_bloc.dart';

abstract class GeminiState extends Equatable {
 const GeminiState();

 @override
 List<Object> get props => [];
}

class GeminiInitial extends GeminiState {}
class GeminiLoading extends GeminiState {}

class GeminiActionSuccess extends GeminiState {
 final GeminiActionResponse response;
 const GeminiActionSuccess({required this.response});

 @override
 List<Object> get props => [response];
}

class GeminiFailure extends GeminiState {
 final String error;
 const GeminiFailure({required this.error});

 @override
 List<Object> get props => [error];
}