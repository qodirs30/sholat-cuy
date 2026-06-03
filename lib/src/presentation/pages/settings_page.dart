import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../domain/entities/prayer_time.dart';
import '../providers/settings_provider.dart';
import '../providers/prayer_provider.dart';
import '../widgets/frosted_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final settings = Provider.of<SettingsProvider>(context, listen: false).settings;
    _latController = TextEditingController(text: settings.manualLatitude.toString());
    _lngController = TextEditingController(text: settings.manualLongitude.toString());
    _nameController = TextEditingController(text: settings.manualLocationName);
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final prayerProvider = Provider.of<PrayerProvider>(context);
    final settings = settingsProvider.settings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? AppColors.nightGradient : AppColors.dayGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 15.0, bottom: 120.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Text(
                  'Pengaturan',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 25),

                // 1. Location Settings Card
                Text(
                  'Lokasi & Koordinat',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                FrostedCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Gunakan GPS Otomatis', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Mengambil lokasi real-time dari perangkat'),
                        activeColor: AppColors.emeraldGreen,
                        value: settings.useGps,
                        onChanged: (val) {
                          settingsProvider.updateLocationMode(val).then((_) {
                            prayerProvider.fetchPrayerTimes(settings: settingsProvider.settings);
                          });
                        },
                      ),
                      if (!settings.useGps) ...[
                        const Divider(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lokasi (Kota/Kabupaten)',
                            icon: Icon(Icons.location_city, color: AppColors.emeraldGreen),
                          ),
                          validator: (val) => val == null || val.isEmpty ? 'Lokasi tidak boleh kosong' : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Latitude',
                                  icon: Icon(Icons.map, color: AppColors.emeraldGreen),
                                ),
                                validator: (val) => double.tryParse(val ?? '') == null ? 'Format salah' : null,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                controller: _lngController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Longitude',
                                ),
                                validator: (val) => double.tryParse(val ?? '') == null ? 'Format salah' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emeraldGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text('Simpan Lokasi Manual'),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              final lat = double.parse(_latController.text);
                              final lng = double.parse(_lngController.text);
                              settingsProvider.updateManualLocation(lat, lng, _nameController.text).then((_) {
                                prayerProvider.fetchPrayerTimes(settings: settingsProvider.settings);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Lokasi manual berhasil disimpan!')),
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 2. Alarm & Calculation Settings
                Text(
                  'Kalkulasi & Alarm',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                FrostedCard(
                  child: Column(
                    children: [
                      // Calculation Method dropdown
                      DropdownButtonFormField<String>(
                        dropdownColor: isDark ? Colors.grey[900]?.withOpacity(0.95) : Colors.white.withOpacity(0.95),
                        decoration: const InputDecoration(
                          labelText: 'Metode Kalkulasi',
                          icon: Icon(Icons.calculate, color: AppColors.emeraldGreen),
                        ),
                        value: settings.calculationMethod,
                        items: const [
                          DropdownMenuItem(value: 'Kemenag', child: Text('Kemenag RI (Standard Indonesia)')),
                          DropdownMenuItem(value: 'ISNA', child: Text('ISNA (North America)')),
                          DropdownMenuItem(value: 'MWL', child: Text('Muslim World League')),
                          DropdownMenuItem(value: 'EGYPT', child: Text('Egyptian General Authority')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            settingsProvider.updateCalculationMethod(val).then((_) {
                              prayerProvider.fetchPrayerTimes(settings: settingsProvider.settings);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),

                      // Adzan Sound dropdown
                      DropdownButtonFormField<String>(
                        dropdownColor: isDark ? Colors.grey[900]?.withOpacity(0.95) : Colors.white.withOpacity(0.95),
                        decoration: const InputDecoration(
                          labelText: 'Suara Alarm Adzan',
                          icon: Icon(Icons.volume_up, color: AppColors.emeraldGreen),
                        ),
                        value: settings.adzanSound,
                        items: const [
                          DropdownMenuItem(value: 'adzan_1', child: Text('Adzan Makkah')),
                          DropdownMenuItem(value: 'adzan_2', child: Text('Adzan Madinah')),
                          DropdownMenuItem(value: 'beep', child: Text('Beep Pendek')),
                          DropdownMenuItem(value: 'silent', child: Text('Senyap')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            settingsProvider.updateAdzanSound(val).then((_) {
                              prayerProvider.fetchPrayerTimes(settings: settingsProvider.settings);
                            });
                          }
                        },
                      ),
                      const Divider(height: 30),

                      // Spam mode toggle
                      SwitchListTile(
                        title: const Text('Mode Spam Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Mengirim alarm setiap 2 menit hingga Anda membuka aplikasi'),
                        activeColor: AppColors.emeraldGreen,
                        value: settings.spamEnabled,
                        onChanged: (val) {
                          settingsProvider.updateSpamEnabled(val).then((_) {
                            prayerProvider.fetchPrayerTimes(settings: settingsProvider.settings);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 3. App Display Preference Card
                Text(
                  'Format & Bahasa',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                FrostedCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Format 24 Jam'),
                        activeColor: AppColors.emeraldGreen,
                        value: settings.twentyFourHourFormat,
                        onChanged: (val) {
                          settingsProvider.updateTwentyFourHourFormat(val);
                        },
                      ),
                      const Divider(height: 15),
                      DropdownButtonFormField<String>(
                        dropdownColor: isDark ? Colors.grey[900]?.withOpacity(0.95) : Colors.white.withOpacity(0.95),
                        decoration: const InputDecoration(
                          labelText: 'Bahasa Aplikasi',
                          icon: Icon(Icons.language, color: AppColors.emeraldGreen),
                        ),
                        value: settings.languageCode,
                        items: const [
                          DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            settingsProvider.updateLanguage(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
