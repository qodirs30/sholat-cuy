import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/core/di/injection.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/utils/foreground_service_helper.dart';
import 'src/presentation/providers/navigation_provider.dart';
import 'src/presentation/providers/prayer_provider.dart';
import 'src/presentation/providers/settings_provider.dart';
import 'src/presentation/pages/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection (GetIt)
  await initDI();

  // Initialize Android Foreground Service Task
  await ForegroundServiceHelper.initForegroundTask();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(
            getUserSettingsUseCase: sl(),
            saveUserSettingsUseCase: sl(),
          )..loadSettings(),
        ),
        ChangeNotifierProvider<PrayerProvider>(
          create: (_) => PrayerProvider(
            getPrayerTimesUseCase: sl(),
          ),
        ),
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider.isLoading) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MaterialApp(
            title: 'SHOLAT cuy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system, // Auto detect system theme
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
