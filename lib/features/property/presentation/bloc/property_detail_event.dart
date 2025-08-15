part of 'property_detail_bloc.dart';

abstract class PropertyDetailEvent extends Equatable {
 const PropertyDetailEvent();

 @override
 List<Object> get props => [];
}

class FetchPropertyDetail extends PropertyDetailEvent {
 final String id;
 const FetchPropertyDetail({required this.id});

 @override
 List<Object> get props => [id];
}