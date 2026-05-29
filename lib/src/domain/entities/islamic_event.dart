class IslamicEvent {
  final String name;
  final String description;
  final int hijriMonth; // 1-12 (Muharram = 1, Ramadhan = 9, Syawal = 10, Dzulhijjah = 12)
  final int hijriDay;

  const IslamicEvent({
    required this.name,
    required this.description,
    required this.hijriMonth,
    required this.hijriDay,
  });

  /// The month display names in Hijri calendar
  static String getHijriMonthName(int month) {
    const months = [
      'Muharram',
      'Safar',
      'Rabiul Awal',
      'Rabiul Akhir',
      'Jumadil Awal',
      'Jumadil Akhir',
      'Rajab',
      'Sya\'ban',
      'Ramadhan',
      'Syawal',
      'Dzulqa\'dah',
      'Dzulhijjah'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  String get hijriDateString => '$hijriDay ${getHijriMonthName(hijriMonth)}';

  /// Standard list of Islamic holidays
  static List<IslamicEvent> get staticEvents {
    return const [
      IslamicEvent(
        name: 'Tahun Baru Islam',
        description: 'Menandai dimulainya tahun baru Hijriah (1 Muharram).',
        hijriMonth: 1,
        hijriDay: 1,
      ),
      IslamicEvent(
        name: 'Hari Asyura',
        description: 'Hari ke-10 bulan Muharram, sangat dianjurkan untuk berpuasa sunnah.',
        hijriMonth: 1,
        hijriDay: 10,
      ),
      IslamicEvent(
        name: 'Maulid Nabi Muhammad SAW',
        description: 'Memperingati kelahiran Baginda Nabi Muhammad SAW (12 Rabiul Awal).',
        hijriMonth: 3,
        hijriDay: 12,
      ),
      IslamicEvent(
        name: 'Isra\' Mi\'raj',
        description: 'Memperingati perjalanan malam Nabi Muhammad SAW menerima perintah shalat 5 waktu (27 Rajab).',
        hijriMonth: 7,
        hijriDay: 27,
      ),
      IslamicEvent(
        name: 'Awal Bulan Ramadhan',
        description: 'Hari pertama umat Islam memulai ibadah puasa wajib Ramadhan (1 Ramadhan).',
        hijriMonth: 9,
        hijriDay: 1,
      ),
      IslamicEvent(
        name: 'Nuzulul Qur\'an',
        description: 'Memperingati turunnya ayat pertama Al-Qur\'an (17 Ramadhan).',
        hijriMonth: 9,
        hijriDay: 17,
      ),
      IslamicEvent(
        name: 'Hari Raya Idul Fitri',
        description: 'Hari kemenangan umat Islam setelah sebulan penuh berpuasa Ramadhan (1 Syawal).',
        hijriMonth: 10,
        hijriDay: 1,
      ),
      IslamicEvent(
        name: 'Hari Raya Idul Adha',
        description: 'Memperingati kurban Nabi Ibrahim AS dan puncak ibadah Haji (10 Dzulhijjah).',
        hijriMonth: 12,
        hijriDay: 10,
      ),
      IslamicEvent(
        name: 'Hari Tasyrik',
        description: 'Hari-hari dilarang berpuasa setelah Idul Adha (11, 12, 13 Dzulhijjah).',
        hijriMonth: 12,
        hijriDay: 11,
      ),
    ];
  }
}
