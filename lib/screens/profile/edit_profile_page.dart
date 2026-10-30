import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_sizes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;

  String _selectedEmoji = '👤';
  final List<String> _emojis = [
    '👤', '🐱', '🐶', '🦊', '🐼', '🦁', '🐧', '🐲', '🌸', '🍀'
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(
      text: auth.displayName ?? auth.username ?? '',
    );
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _selectedEmoji = auth.avatarEmoji ?? '👤';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final profileOk = await auth.updateProfile(
      displayName: _nameController.text.trim(),
      avatarEmoji: _selectedEmoji,
    );

    if (!profileOk) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
            content: Text(auth.error ?? l10n.loginFailedTitle),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    final passwordBaru = _passwordController.text;
    if (passwordBaru.isEmpty) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.profileUpdated)),
      );
      navigator.pop();
      return;
    }

    final passOk = await auth.updatePassword(passwordBaru);
    if (!mounted) return;

    if (!passOk) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.profileSavedPasswordFailed),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      navigator.pop();
      return;
    }

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.profilePasswordSaved)),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.isLoading;
    final passwordBaru = _passwordController.text;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.chooseAvatar,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.spacingS),
              Wrap(
                spacing: AppSizes.spacingS,
                runSpacing: AppSizes.spacingS,
                children: _emojis.map((emoji) {
                  final isSelected = _selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmoji = emoji),
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryGreen.withValues(alpha: 0.2)
                            : Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child:
                          Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.spacingL),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.displayNameLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                validator: (val) {
                  final v = (val ?? '').trim();
                  if (v.isEmpty) return l10n.displayNameEmpty;
                  if (v.length > 30) return l10n.displayNameMaxLength;
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spacingM),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.newPasswordLabel,
                  helperText: l10n.newPasswordHint,
                  helperMaxLines: 3,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length < 6) {
                    return l10n.passwordMinLength;
                  }
                  return null;
                },
              ),
              if (passwordBaru.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacingM),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPasswordHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (val) {
                    if (passwordBaru.isNotEmpty && val != passwordBaru) {
                      return l10n.confirmPasswordMismatch;
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: AppSizes.spacingXl),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(l10n.saveChanges,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}