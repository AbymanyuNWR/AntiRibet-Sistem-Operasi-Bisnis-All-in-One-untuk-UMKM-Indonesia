import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
// import '../../domain/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // final AuthRepository authRepository;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Logic cek token dari secure storage & verify ke API (authRepository.checkAuth())
      await Future.delayed(const Duration(seconds: 1)); // Mock
      // emit(AuthAuthenticated(user));
      emit(AuthUnauthenticated()); // Default mock
    } catch (e) {
      emit(AuthError('Gagal memverifikasi sesi.'));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Logic hit endpoint login via repository
      // final user = await authRepository.login(event.email, event.password);
      await Future.delayed(const Duration(seconds: 2)); // Mock
      emit(AuthAuthenticated({'email': event.email, 'name': 'Merchant Owner'}));
    } catch (e) {
      emit(const AuthError('Kredensial tidak valid.'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // await authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(const AuthError('Gagal logout.'));
    }
  }
}
