// Penjelasan:
// BLoC untuk halaman detail properti.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:waisaka_property/features/property/data/models/property_model.dart';
import 'package:waisaka_property/features/property/data/repositories/property_repository.dart';

part 'property_detail_event.dart';
part 'property_detail_state.dart';

class PropertyDetailBloc extends Bloc<PropertyDetailEvent, PropertyDetailState> {
 final PropertyRepository _propertyRepository;

 PropertyDetailBloc({required PropertyRepository propertyRepository})
     : _propertyRepository = propertyRepository,
       super(PropertyDetailInitial()) {
   on<FetchPropertyDetail>(_onFetchDetail);
 }

 Future<void> _onFetchDetail(FetchPropertyDetail event, Emitter<PropertyDetailState> emit) async {
   emit(PropertyDetailLoading());
   try {
     final property = await _propertyRepository.getPropertyDetail(event.id);
     emit(PropertyDetailLoadSuccess(property: property));
   } catch (e) {
     emit(PropertyDetailLoadFailure(error: e.toString()));
   }
 }
}