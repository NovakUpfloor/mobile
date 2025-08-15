// Penjelasan:
// BLoC untuk halaman utama (Home).
// - Mengelola state untuk data properti dan artikel.
// - Juga menangani event pencarian dari voice command.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:waisaka_property/features/article/data/models/article_model.dart';
import 'package:waisaka_property/features/article/data/repositories/article_repository.dart';
import 'package:waisaka_property/features/gemini/data/repositories/gemini_repository.dart';
import 'package:waisaka_property/features/property/data/models/property_model.dart';
import 'package:waisaka_property/features/property/data/repositories/property_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
 final PropertyRepository _propertyRepository;
 final ArticleRepository _articleRepository;
 final GeminiRepository _geminiRepository;

 HomeBloc({
   required PropertyRepository propertyRepository,
   required ArticleRepository articleRepository,
   required GeminiRepository geminiRepository,
 })  : _propertyRepository = propertyRepository,
       _articleRepository = articleRepository,
       _geminiRepository = geminiRepository,
       super(HomeInitial()) {
   on<LoadHomeData>(_onLoadHomeData);
 }

 Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
   emit(HomeLoading());
   try {
     final properties = await _propertyRepository.getProperties();
     final articles = await _articleRepository.getArticles();
     emit(HomeLoadSuccess(properties: properties, articles: articles));
   } catch (e) {
     emit(HomeLoadFailure(error: e.toString()));
   }
 }
}