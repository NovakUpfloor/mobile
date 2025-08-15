// Penjelasan:
// BLoC (Business Logic Component) untuk fitur autentikasi.
// - Menerima Events (seperti AuthLoginRequested).
// - Berinteraksi dengan AuthRepository untuk melakukan aksi.
// - Mengeluarkan (emit) States (seperti AuthLoading, AuthSuccess, AuthFailure)
//   untuk memberi tahu UI tentang perubahan yang terjadi.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waisaka_property/features/auth/data/models/package_model.dart';
import 'package:waisaka_property/features/auth/data/models/user.dart';
import 'package:waisaka_property/features/auth/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
 final AuthRepository _authRepository;

 AuthBloc({required AuthRepository authRepository})
     : _authRepository = authRepository,
       super(AuthInitial()) {
   on<AuthLoginRequested>(_onLoginRequested);
   on<AuthRegisterRequested>(_onRegisterRequested);
   on<FetchPackages>(_onFetchPackages);
   on<AuthLogoutRequested>(_onLogoutRequested);
   on<FetchUserProfile>(_onFetchUserProfile);
 }

 Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
   emit(AuthLoading());
   try {
     final user = await _authRepository.login(username: event.username, password: event.password);
     emit(AuthSuccess(user: user));
   } catch (e) {
     emit(AuthFailure(error: e.toString()));
   }
 }

 Future<void> _onRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
   emit(AuthLoading());
   try {
     await _authRepository.register(
       name: event.name,
       username: event.username,
       email: event.email,
       password: event.password,
       packageId: event.packageId,
     );
     emit(AuthRegisterSuccess());
   } catch (e) {
     emit(AuthFailure(error: e.toString()));
   }
 }

 Future<void> _onFetchPackages(FetchPackages event, Emitter<AuthState> emit) async {
   emit(AuthPackagesLoading());
   try {
     final packages = await _authRepository.getPackages();
     emit(AuthPackagesLoadSuccess(packages: packages));
   } catch (e) {
     emit(AuthFailure(error: e.toString()));
   }
 }
 
 Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
   try {
     await _authRepository.logout();
     emit(AuthLogoutSuccess());
   } catch (e) {
     // Tidak perlu emit error, langsung logout saja
     emit(AuthLogoutSuccess());
   }
 }

 Future<void> _onFetchUserProfile(FetchUserProfile event, Emitter<AuthState> emit) async {
   emit(UserProfileLoading());
   try {
     final user = await _authRepository.getUserProfile();
     emit(UserProfileLoaded(user: user));
   } catch (e) {
     emit(AuthFailure(error: e.toString()));
   }
 }
}