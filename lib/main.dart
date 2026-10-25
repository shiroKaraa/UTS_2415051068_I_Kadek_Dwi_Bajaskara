import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/app_theme.dart';
import 'core/theme_controller.dart';
import 'screens/responsive_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ try/catch agar tidak crash jika .env tidak tersedia.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Gagal memuat .env: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Dengarkan ThemeController agar perubahan tema langsung ter-apply.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.mode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'MediaShelf',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const ResponsiveShell(),
        );
      },
    );
  }
}