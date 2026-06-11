import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/api/api_config.dart';
import 'package:sacred_app/core/auth/dev_auth_store.dart';
import 'package:sacred_app/core/auth/tier_cache.dart';

class AuthState {
  final bool isAuthenticated;
  final String? token;
  final String? role;
  final String? userId;
  final String? userName;
  final String tier;
  final DateTime? tierExpiresAt;

  const AuthState({
    this.isAuthenticated = false,
    this.token,
    this.role,
    this.userId,
    this.userName,
    this.tier = 'free',
    this.tierExpiresAt,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    String? role,
    String? userId,
    String? userName,
    String? tier,
    DateTime? tierExpiresAt,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      tier: tier ?? this.tier,
      tierExpiresAt: tierExpiresAt ?? this.tierExpiresAt,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'sacred_jwt_token';
  final _devAuth = DevAuthStore();

  bool get _useDevAuth => shouldUseDevAuth;

  bool _isConnectionError(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout;

  @override
  Future<AuthState> build() async {
    if (_useDevAuth) {
      await _devAuth.ensureSeeded();
    }

    final token = await _storage.read(key: _tokenKey);
    if (token == null) return const AuthState();

    if (isDevAuthToken(token) && !_useDevAuth) {
      await _storage.delete(key: _tokenKey);
      return const AuthState();
    }

    if (_useDevAuth && isDevAuthToken(token)) {
      final user = await _devAuth.findByToken(token);
      if (user == null) {
        await _storage.delete(key: _tokenKey);
        return const AuthState();
      }
      final authState = _authStateFromDevUser(user, token);
      await _persistTier(authState);
      return authState;
    }

    try {
      final user = await ref.read(apiClientProvider).get(
            '/auth/me',
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );
      final data = user.data as Map<String, dynamic>;
      final authState = _authStateFromUser(data, token);
      await _persistTier(authState);
      return authState;
    } catch (_) {
      await _storage.delete(key: _tokenKey);
      return const AuthState();
    }
  }

  Future<void> login(String email, String password) async {
    final previous = state;
    state = const AsyncLoading<AuthState>().copyWithPrevious(previous);
    try {
      if (isApiConfigured) {
        try {
          await _loginViaApi(email, password);
          return;
        } on DioException catch (e) {
          if (ApiConfig.preferDevAuth &&
              kDebugMode &&
              _isConnectionError(e)) {
            await _loginViaDevAuth(email, password);
            return;
          }
          rethrow;
        }
      }

      await _loginViaDevAuth(email, password);
    } catch (e, st) {
      state = AsyncError<AuthState>(e, st).copyWithPrevious(previous);
    }
  }

  Future<void> _loginViaApi(String email, String password) async {
    final res = await ref.read(apiClientProvider).post(
          '/auth/login',
          data: {'email': email, 'password': password},
        );
    final data = res.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = data['user'] as Map<String, dynamic>;
    await _storage.write(key: _tokenKey, value: token);
    final authState = _authStateFromUser(user, token);
    await _persistTier(authState);
    state = AsyncData(authState);
  }

  Future<void> _loginViaDevAuth(String email, String password) async {
    if (!kDebugMode) {
      throw Exception('Серверт холбогдож чадсангүй');
    }
    await _devAuth.ensureSeeded();
    final user = await _devAuth.login(email, password);
    if (user == null) {
      throw Exception('Имэйл эсвэл нууц үг буруу');
    }
    final token = _devAuth.tokenFor(user);
    await _storage.write(key: _tokenKey, value: token);
    final authState = _authStateFromDevUser(user, token);
    await _persistTier(authState);
    state = AsyncData(authState);
  }

  Future<void> signup(String email, String password, String name) async {
    final previous = state;
    state = const AsyncLoading<AuthState>().copyWithPrevious(previous);
    try {
      if (isApiConfigured) {
        try {
          final res = await ref.read(apiClientProvider).post(
                '/auth/signup',
                data: {'email': email, 'password': password, 'name': name},
              );
          final data = res.data as Map<String, dynamic>;
          final token = data['token'] as String;
          final user = data['user'] as Map<String, dynamic>;
          await _storage.write(key: _tokenKey, value: token);
          final authState = _authStateFromUser(user, token);
          await _persistTier(authState);
          state = AsyncData(authState);
          return;
        } on DioException catch (e) {
          if (ApiConfig.preferDevAuth &&
              kDebugMode &&
              _isConnectionError(e)) {
            // fall through to dev signup
          } else {
            rethrow;
          }
        }
      }

      final user = await _devAuth.signup(email, password, name);
      final token = _devAuth.tokenFor(user);
      await _storage.write(key: _tokenKey, value: token);
      final authState = _authStateFromDevUser(user, token);
      await _persistTier(authState);
      state = AsyncData(authState);
    } catch (e, st) {
      state = AsyncError<AuthState>(e, st).copyWithPrevious(previous);
    }
  }

  Future<void> refreshProfile() async {
    final current = state.valueOrNull;
    if (current?.token == null) return;

    try {
      final userRes = await ref.read(apiClientProvider).get(
            '/auth/me',
            options: Options(
              headers: {'Authorization': 'Bearer ${current!.token}'},
            ),
          );
      var data = userRes.data as Map<String, dynamic>;

      try {
        final statusRes =
            await ref.read(apiClientProvider).get('/subscription/status');
        final status = statusRes.data as Map<String, dynamic>;
        data = {...data, ...status};
      } catch (_) {}

      final authState = _authStateFromUser(data, current.token!);
      await _persistTier(authState);
      state = AsyncData(authState);
    } catch (_) {}
  }

  Future<void> updateTier(String tier, DateTime? expiresAt) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = current.copyWith(tier: tier, tierExpiresAt: expiresAt);
    await _persistTier(updated);
    state = AsyncData(updated);
  }

  Future<void> _persistTier(AuthState authState) async {
    await TierCache.save(authState.tier, authState.tierExpiresAt);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await TierCache.clear();
    state = const AsyncData(AuthState());
  }
}

AuthState _authStateFromDevUser(DevAuthUser user, String token) {
  return AuthState(
    isAuthenticated: true,
    token: token,
    role: user.role,
    userId: user.id,
    userName: user.name,
  );
}

AuthState _authStateFromUser(Map<String, dynamic> data, String token) {
  final expiresRaw = data['tierExpiresAt'] as String? ??
      data['tier_expires_at'] as String? ??
      data['expiresAt'] as String?;
  return AuthState(
    isAuthenticated: true,
    token: token,
    role: data['role'] as String?,
    userId: data['_id'] as String? ?? data['id'] as String?,
    userName: data['name'] as String?,
    tier: data['tier'] as String? ?? 'free',
    tierExpiresAt: expiresRaw != null ? DateTime.tryParse(expiresRaw) : null,
  );
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
