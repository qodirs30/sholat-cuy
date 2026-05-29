import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/constants/colors.dart';
import '../../domain/entities/prayer_time.dart';
import '../providers/prayer_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/frosted_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
      Provider.of<PrayerProvider>(context, listen: false)
          .fetchPrayerTimes(settings: settings);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final schedule = prayerProvider.schedule;
    final current = prayerProvider.currentPrayer;
    final next = prayerProvider.nextPrayer;

    // Fetch dynamic gradient based on the current active prayer
    final backgroundGradient = _getDynamicGradient(current?.type, isDark);

    // Get current Hijri and Gregorian Date/Time
    final now = DateTime.now();
    final hijriNow = HijriCalendar.now();
    final hijriDateString = '${hijriNow.hDay} ${hijriNow.longMonthName} ${hijriNow.hYear} H';
    final gregorianDateString = _getGregorianDateString(now);
    final timeString = DateFormat('HH:mm:ss').format(now);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: backgroundGradient,
        ),
      ),
      child: SafeArea(
        child: prayerProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.emeraldGreen,
                ),
              )
            : RefreshIndicator(
                color: AppColors.emeraldGreen,
                onRefresh: () async {
                  await prayerProvider.fetchPrayerTimes(settings: settingsProvider.settings);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Location & Dates in glass card (high contrast)
                      FrostedCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        borderRadius: 20.0,
                        color: Colors.black.withOpacity(isDark ? 0.35 : 0.22),
                        borderColor: Colors.white.withOpacity(0.12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: AppColors.emeraldGreen,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          schedule?.locationName ?? 'Memuat lokasi...',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.2,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, size: 22, color: Colors.white),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    prayerProvider.fetchPrayerTimes(
                                      settings: settingsProvider.settings,
                                    );
                                  },
                                ),
                              ],
                            ),
                            Divider(height: 16, thickness: 0.5, color: Colors.white.withOpacity(0.15)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hijriah: $hijriDateString',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Masehi: $gregorianDateString',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'WAKTU SEKARANG',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withOpacity(0.6),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      timeString,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Countdown glass card to next prayer
                      if (next != null)
                        FrostedCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Menuju ${next.name}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                prayerProvider.timeToNextString,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 15),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: prayerProvider.prayerProgress,
                                  minHeight: 8,
                                  backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emeraldGreen),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    current != null
                                        ? '${current.name} (${DateFormat('HH:mm').format(current.time)})'
                                        : '',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${next.name} (${DateFormat('HH:mm').format(next.time)})',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 30),

                      // Prayer schedule list
                      Text(
                        'Jadwal Hari Ini',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 15),

                      if (schedule != null)
                        ...schedule.prayers.map((prayer) {
                          final isCurrent = current?.type == prayer.type;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: FrostedCard(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                              color: isCurrent
                                  ? AppColors.emeraldGreen.withOpacity(0.25)
                                  : null,
                              borderColor: isCurrent
                                  ? AppColors.emeraldGreen.withOpacity(0.5)
                                  : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getPrayerIcon(prayer.type),
                                        color: isCurrent ? AppColors.emeraldGreen : (isDark ? Colors.white70 : Colors.black54),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 15),
                                      Text(
                                        prayer.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    DateFormat(settingsProvider.settings.twentyFourHourFormat ? 'HH:mm' : 'hh:mm a').format(prayer.time),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String _getGregorianDateString(DateTime dt) {
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[dt.weekday == 7 ? 0 : dt.weekday];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  IconData _getPrayerIcon(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return Icons.brightness_3;
      case PrayerType.sunrise:
        return Icons.wb_sunny_outlined;
      case PrayerType.dhuhr:
        return Icons.wb_sunny;
      case PrayerType.asr:
        return Icons.wb_cloudy_outlined;
      case PrayerType.maghrib:
        return Icons.nights_stay_outlined;
      case PrayerType.isha:
        return Icons.nights_stay;
    }
  }

  List<Color> _getDynamicGradient(PrayerType? currentPrayerType, bool isDark) {
    if (isDark) {
      return AppColors.nightGradient;
    }
    if (currentPrayerType == null) {
      return AppColors.dayGradient;
    }
    switch (currentPrayerType) {
      case PrayerType.fajr:
        return AppColors.sunriseGradient;
      case PrayerType.sunrise:
        return AppColors.dayGradient;
      case PrayerType.dhuhr:
        return AppColors.dayGradient;
      case PrayerType.asr:
        return AppColors.twilightGradient;
      case PrayerType.maghrib:
        return AppColors.twilightGradient;
      case PrayerType.isha:
        return AppColors.nightGradient;
    }
  }
}
