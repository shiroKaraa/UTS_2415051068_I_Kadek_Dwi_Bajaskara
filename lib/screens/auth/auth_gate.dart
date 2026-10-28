import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../onboarding_page.dart';
import '../responsive_shell.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    if (settings.isLoading) {
      return const _SplashScreen();
    }

    if (!settings.hasSeenOnboarding) {
      return const OnboardingPage(key: ValueKey('onboarding'));
    }

    if (auth.status == AuthStatus.unknown) {
      return const _SplashScreen();
    }

    if (auth.isAuthenticated) {
      return const ResponsiveShell(key: ValueKey('main_shell')); 
    }

    return const LoginPage(key: ValueKey('login_page'));
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}