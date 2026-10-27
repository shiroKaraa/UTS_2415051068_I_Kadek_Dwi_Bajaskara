import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/app_theme.dart';
import 'core/app_config.dart';
import 'providers/settings_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/collection_provider.dart'; 
import 'providers/category_provider.dart';
import 'repositories/collection_repository.dart'; 
import 'services/supabase_collection_service.dart'; 
import 'screens/responsive_shell.dart';
import 'screens/onboarding_page.dart'; // <-- Import Onboarding

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
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, CollectionProvider>(
          create: (context) => CollectionProvider(
            CollectionRepository(SupabaseCollectionService()),
          ),
          update: (context, settings, previous) {
            previous?.bindDevice(settings.deviceId);
            return previous!;
          },
        ),
        ChangeNotifierProxyProvider<SettingsProvider, CategoryProvider>(
          create: (_) => CategoryProvider(),
          update: (_, settings, previous) {
            previous?.bindDevice(settings.deviceId);
            return previous!;
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
            // Cek Onboarding
            home: settings.hasSeenOnboarding 
                ? const ResponsiveShell() 
                : const OnboardingPage(),
          );
        },
      ),
    );
  }
}