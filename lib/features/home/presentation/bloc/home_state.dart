part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
 const HomeState();

 @override
 List<Object> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}

class HomeLoadSuccess extends HomeState {
 final List<Property> properties;
 final List<Article> articles;

 const HomeLoadSuccess({required this.properties, required this.articles});

 @override
 List<Object> get props => [properties, articles];
}

class HomeLoadFailure extends HomeState {
 final String error;
 const HomeLoadFailure({required this.error});

 @override
 List<Object> get props => [error];
}