import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_sizes.dart';
import '../../../providers/auth_provider.dart';
import 'register_page.dart';
import 'guest_info_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!ok) {
      final l10n = AppLocalizations.of(context)!;
      final msg = auth.error ?? l10n.loginFailedTitle;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.spacingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSizes.spacingXl),
                    Container(
                      width: 88,
                      height: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        size: 44,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXs),
                    Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXl),
                    TextFormField(
                      controller: _usernameController,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) => newValue.copyWith(
                            text: newValue.text.toLowerCase(),
                          ),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: l10n.usernameLabel,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) {
                        final v = (val ?? '').trim();
                        if (v.isEmpty) return l10n.usernameRequired;
                        if (v.length < 3) return l10n.usernameMinLength;
                        if (v.length > 20) return l10n.usernameMaxLength;
                        if (!RegExp(r'^[a-z0-9_]+$').hasMatch(v)) {
                          return l10n.usernameInvalidChars;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? l10n.showPassword
                              : l10n.hidePassword,
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return l10n.passwordRequired;
                        }
                        if (val.length < 6) return l10n.passwordMinLength;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingXl),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _submit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(
                            isLoading ? l10n.processing : l10n.loginButton),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.noAccountYet,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                          child: Text(l10n.registerButton),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.spacingM),
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GuestInfoPage(),
                                ),
                              );
                            },
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Masuk sebagai Tamu'), 
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXs),
                    Text(
                      'Data koleksi tidak akan tersimpan ke akun. '
                      'Backup manual diperlukan.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),                  
                    const SizedBox(height: AppSizes.spacingXl),
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