import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../core/constants/colors.dart';
import '../../domain/entities/islamic_event.dart';
import '../providers/settings_provider.dart';
import '../widgets/frosted_card.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get current Hijri date
    final hijriNow = HijriCalendar.now();

    // Generate upcoming holidays list
    final events = IslamicEvent.staticEvents;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? AppColors.nightGradient : AppColors.dayGradient,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Text(
                'Kalender Hijriah',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),

              // Current Month Glass Display Card
              FrostedCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hijriNow.longMonthName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.emeraldGreen,
                            ),
                          ),
                          Text(
                            'Tahun ${hijriNow.hYear} Hijriah',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.emeraldGreen),
                              const SizedBox(width: 8),
                              Text(
                                'Hari ini: ${hijriNow.hDay} ${hijriNow.longMonthName} ${hijriNow.hYear} H',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Islamic Holidays Header
              Text(
                'Hari Besar Islam',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 15),

              // Checklist of holidays
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  
                  // Check if this event matches the current Hijri month
                  final isCurrentMonth = hijriNow.hMonth == event.hijriMonth;
                  // Determine if the event has passed this month
                  final isUpcoming = event.hijriMonth > hijriNow.hMonth || 
                      (isCurrentMonth && event.hijriDay >= hijriNow.hDay);

                  // Convert Hijri date to Gregorian
                  int targetYear = hijriNow.hYear;
                  DateTime gDate;
                  try {
                    gDate = hijriNow.hijriToGregorian(targetYear, event.hijriMonth, event.hijriDay);
                    final now = DateTime.now();
                    // If it has already passed in this Hijri year, project the Gregorian date for the next Hijri year
                    if (gDate.isBefore(DateTime(now.year, now.month, now.day))) {
                      targetYear = hijriNow.hYear + 1;
                      gDate = hijriNow.hijriToGregorian(targetYear, event.hijriMonth, event.hijriDay);
                    }
                  } catch (_) {
                    gDate = DateTime.now();
                  }
                  final gregorianString = _getGregorianDateString(gDate);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: FrostedCard(
                      padding: const EdgeInsets.all(16.0),
                      color: isCurrentMonth
                          ? AppColors.emeraldGreen.withOpacity(0.20)
                          : (isUpcoming ? null : Colors.black.withOpacity(0.08)),
                      borderColor: isCurrentMonth
                          ? AppColors.emeraldGreen.withOpacity(0.4)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  event.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isUpcoming
                                        ? (isDark ? Colors.white : Colors.black)
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isCurrentMonth
                                          ? AppColors.emeraldGreen
                                          : (isUpcoming ? AppColors.darkGrey : Colors.grey),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      event.hijriDateString,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    gregorianString,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isUpcoming
                                          ? AppColors.emeraldGreen
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: isUpcoming
                                  ? (isDark ? Colors.white70 : Colors.black87)
                                  : Colors.grey,
                            ),
                          ),
                          if (isCurrentMonth) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: AppColors.emeraldGreen),
                                const SizedBox(width: 4),
                                Text(
                                  'Bulan ini!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.emeraldGreen,
                                  ),
                                ),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGregorianDateString(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
