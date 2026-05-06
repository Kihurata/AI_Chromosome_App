import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/auth/auth_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/shared/form/app_text_field.dart';
import '../../widgets/shared/form/app_buttons.dart';
import '../../../core/services/notification_factory.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorWithType) {
          NotificationFactory.show(
            context,
            type: state.type,
            message: state.message,
            onRetry: () => context.read<AuthCubit>().retryLogin(),
          );
        } else if (state is AuthError) {
          // Legacy fallback
          NotificationFactory.showError(context, state.message);
        }
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(40.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13), // 0.05 opacity approx
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.biotech, size: 64, color: AppColors.primaryBlue),
                    const SizedBox(height: 24),
                    Text(
                      "MEDCORE CRM",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primaryBlue,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Chromosome Karyotyping System",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 48),
                    AppTextField(
                      controller: _emailController,
                      hintText: "Email Bác sĩ/Nhân viên",
                      prefixIcon: Icons.email_outlined,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập Email" : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passwordController,
                      obscureText: true,
                      hintText: "Mật khẩu",
                      prefixIcon: Icons.lock_outline,
                      validator: (value) => value == null || value.isEmpty ? "Vui lòng nhập mật khẩu" : null,
                    ),
                    const SizedBox(height: 32),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return AppPrimaryButton(
                          text: "ĐĂNG NHẬP",
                          isLoading: state is AuthLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                            }
                          },
                          width: double.infinity,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Quên mật khẩu? Liên hệ Admin", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

