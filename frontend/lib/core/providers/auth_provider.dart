import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/nav_item.dart';
import '../../logic/bloc/auth/auth_cubit.dart';

/// Snapshot of auth state exposed to Riverpod
class AuthSnapshot {
  final User? user;
  final AppRole? role;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  const AuthSnapshot({
    this.user,
    this.role,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  const AuthSnapshot.initial() : this(isLoading: true);
  const AuthSnapshot.unauthenticated() : this();

  factory AuthSnapshot.error(String msg) => AuthSnapshot(errorMessage: msg);
  factory AuthSnapshot.authenticated(User u, AppRole r) =>
      AuthSnapshot(user: u, role: r, isAuthenticated: true);

  String get userInitial {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName![0].toUpperCase();
    }
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user!.email![0].toUpperCase();
    }
    return '?';
  }

  String get displayName =>
      user?.displayName ?? user?.email ?? 'Người dùng';
}

/// Riverpod Notifier (Riverpod 3.x API)
class AuthNotifier extends Notifier<AuthSnapshot> {
  @override
  AuthSnapshot build() => const AuthSnapshot.initial();

  void update(AuthState blocState) {
    if (blocState is Authenticated) {
      state = AuthSnapshot.authenticated(
        blocState.user,
        AppRole.fromString(blocState.role),
      );
    } else if (blocState is Unauthenticated) {
      state = const AuthSnapshot.unauthenticated();
    } else if (blocState is AuthLoading || blocState is AuthInitial) {
      state = const AuthSnapshot.initial();
    } else if (blocState is AuthError) {
      state = AuthSnapshot.error(blocState.message);
    }
  }
}

/// Provider
final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthSnapshot>(AuthNotifier.new);

/// Bridges BLoC AuthCubit → Riverpod in the widget tree.
/// Place this once inside ProviderScope, wrapping the app router.
class AuthBlocBridge extends StatelessWidget {
  final Widget child;
  const AuthBlocBridge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, blocState) {
        final container = ProviderScope.containerOf(context, listen: false);
        container.read(authNotifierProvider.notifier).update(blocState);
      },
      child: _SyncOnMount(child: child),
    );
  }
}

class _SyncOnMount extends StatefulWidget {
  final Widget child;
  const _SyncOnMount({required this.child});

  @override
  State<_SyncOnMount> createState() => _SyncOnMountState();
}

class _SyncOnMountState extends State<_SyncOnMount> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentState = context.read<AuthCubit>().state;
      final container = ProviderScope.containerOf(context, listen: false);
      container.read(authNotifierProvider.notifier).update(currentState);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

