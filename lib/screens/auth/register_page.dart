import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_sizes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      username: _usernameController.text,
      password: _passwordController.text,
      confirmPassword: _confirmController.text,
    );

    if (!mounted) return;

    if (!ok) {
      final l10n = AppLocalizations.of(context)!;
      final msg = auth.error ?? l10n.registerFailedTitle;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerButton)),
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
                    Text(
                      l10n.registerHeader,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXs),
                    Text(
                      l10n.registerSubtitle,
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
                      decoration: InputDecoration(
                        labelText: l10n.usernameLabel,
                        helperText: l10n.usernameHint,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) {
                        final v = (val ?? '').trim();
                        if (v.isEmpty) return l10n.usernameRequired;
                        if (v.length < 3) return l10n.usernameMinLength;
                        if (v.length > 20) return l10n.usernameMaxLength;
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
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
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        helperText: l10n.passwordHint,
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
                    const SizedBox(height: AppSizes.spacingM),

                    TextFormField(
                      controller: _confirmController,
                      enabled: !isLoading,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.confirmPasswordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _obscureConfirm
                              ? l10n.showPassword
                              : l10n.hidePassword,
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return l10n.confirmPasswordRequired;
                        }
                        if (val != _passwordController.text) {
                          return l10n.confirmPasswordNotMatch;
                        }
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
                            : const Icon(Icons.person_add_alt_1),
                        label: Text(
                            isLoading ? l10n.processing : l10n.registerButton),
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
                    Text(
                      l10n.registerTerms,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    Container(
                      padding: const EdgeInsets.all(AppSizes.spacingS),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSizes.radiusS),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 18, color: Colors.orangeAccent),
                          const SizedBox(width: AppSizes.spacingS),
                          Expanded(
                            child: Text(
                              l10n.noPasswordRecovery,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
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