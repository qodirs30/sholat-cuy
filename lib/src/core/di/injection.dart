import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local_ds.dart';
import '../../data/datasources/location_service.dart';
import '../../data/repositories/prayer_repo_impl.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../../domain/usecases/prayer_usecases.dart';
import '../../data/datasources/notification_service.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // External
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPrefs);

  // Services
  final notificationService = NotificationService();
  await notificationService.init();
  sl.registerSingleton<NotificationService>(notificationService);

  sl.registerLazySingleton<LocationService>(() => LocationService());
  sl.registerLazySingleton<LocalDataSource>(
    () => LocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PrayerRepository>(
    () => PrayerRepositoryImpl(
      localDataSource: sl(),
      locationService: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetPrayerTimes(sl()));
  sl.registerLazySingleton(() => GetIslamicEvents());
  sl.registerLazySingleton(() => SaveUserSettings(sl()));
  sl.registerLazySingleton(() => GetUserSettings(sl()));
}
