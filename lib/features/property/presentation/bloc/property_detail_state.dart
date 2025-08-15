part of 'property_detail_bloc.dart';

abstract class PropertyDetailState extends Equatable {
 const PropertyDetailState();

 @override
 List<Object> get props => [];
}

class PropertyDetailInitial extends PropertyDetailState {}
class PropertyDetailLoading extends PropertyDetailState {}

class PropertyDetailLoadSuccess extends PropertyDetailState {
 final Property property;
 const PropertyDetailLoadSuccess({required this.property});

 @override
 List<Object> get props => [property];
}

class PropertyDetailLoadFailure extends PropertyDetailState {
 final String error;
 const PropertyDetailLoadFailure({required this.error});

 @override
 List<Object> get props => [error];
}