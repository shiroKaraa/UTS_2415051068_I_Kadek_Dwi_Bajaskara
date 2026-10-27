import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/app_config.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/collection_provider.dart';
import 'providers/category_provider.dart';
import 'repositories/collection_repository.dart';
import 'services/supabase_collection_service.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: KonfigurasiApp.supabaseUrl,
      publishableKey: KonfigurasiApp.supabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Gagal inisialisasi: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProxyProvider2<AuthProvider, SettingsProvider,
            CollectionProvider>(
          create: (_) => CollectionProvider(
            CollectionRepository(SupabaseCollectionService()),
          ),
          update: (context, auth, settings, previous) {
            final provider = previous ??
                CollectionProvider(
                  CollectionRepository(SupabaseCollectionService()),
                );
            provider.bindUser(auth.userId);
            return provider;
          },
        ),

        ChangeNotifierProxyProvider<SettingsProvider, CategoryProvider>(
          create: (_) => CategoryProvider(),
          update: (_, settings, previous) {
            final provider = previous ?? CategoryProvider();
            provider.bindDevice(settings.deviceId);
            return provider;
          },
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          if (settings.isLoading) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp(
            title: 'Tsuzuki',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id'),
              Locale('en'),
            ],
            locale: settings.locale,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}