import 'package:energy_app/screens/ragional_comparison_screen.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'glass_container.dart';
import '../core/api_service.dart'; // YENİ: ApiService eklendi

// Ekranlar ve Servisler
import '../screens/analysis_screen.dart';
import '../screens/battery_analysis_screen.dart';
import '../core/notification_service.dart';
import '../screens/notification_screen.dart';
import '../screens/optimization_history_screen.dart'; // Optimizasyon Geçmişi
import '../screens/tariff_info_screen.dart'; // Tarife Detayı

// Kart Tipi Enum'u
enum EnergyCardType { production, consumption, gridSale }

// Zaman Periyodu Enum'u
enum TimePeriod { daily, weekly, monthly }

// 1. ÖZET KARTLARI (EnergyStatusCard) - DEĞİŞMEDİ
class EnergyStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final EnergyCardType cardType;

  const EnergyStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.cardType,
  });

  // Menü Oluşturma
  Widget _buildPopupMenu(BuildContext context) {
    List<PopupMenuEntry<String>> menuItems;

    if (cardType == EnergyCardType.production) {
      menuItems = const [
        PopupMenuItem(
          value: 'daily_forecast',
          child: Text(
            '24s Tahmini ve Verim',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'historical_report',
          child: Text(
            'Tarihsel Üretim Raporu',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ];
    } else if (cardType == EnergyCardType.consumption) {
      menuItems = const [
        PopupMenuItem(
          value: 'consumption_distribution',
          child: Text(
            'Tüketim Dağılımı (Cihaz)',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'audit_report',
          child: Text(
            'Enerji Denetim Raporu',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'regional_comparison',
          child: Text(
            'Bölgesel Kıyaslama',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ];
    } else if (cardType == EnergyCardType.gridSale) {
      menuItems = const [
        PopupMenuItem(
          value: 'net_metering',
          child: Text(
            'Tarife ve Mahsuplaşma Detayı',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'optimization_history',
          child: Text(
            'Optimizasyon Geçmişi',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'battery_management',
          child: Text(
            'Batarya Şarj Yönetimi',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ];
    } else {
      menuItems = const [];
    }

    return PopupMenuButton<String>(
      onSelected: (String result) {
        final now = DateTime.now();

        // --- AKSİYONLAR ---

        // 1. ÜRETİM TAHMİNİ (Popup)
        if (result == 'daily_forecast') {
          showDialog(
            context: context,
            builder: (context) => const ProductionForecastDialog(),
          );
        }
        // 2. TÜKETİM DAĞILIMI (Popup)
        else if (result == 'consumption_distribution') {
          showDialog(
            context: context,
            builder: (context) => const ConsumptionDistributionDialog(),
          );
        }
        // 3. BATARYA YÖNETİMİ EKRANINA GİT
        else if (result == 'battery_management') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BatteryAnalysisScreen(),
            ),
          );
        }
        // 4. BÖLGESEL KIYASLAMA EKRANINA GİT (YENİ)
        else if (result == 'regional_comparison') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegionalComparisonScreen(),
            ),
          );
        }
        // 5. TARİFE DETAY EKRANINA GİT (YENİ)
        else if (result == 'net_metering') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TariffInfoScreen()),
          );
        }
        // 6. OPTİMİZASYON GEÇMİŞİ EKRANINA GİT (YENİ)
        else if (result == 'optimization_history') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OptimizationHistoryScreen(),
            ),
          );
        }
        // 7. TARİHSEL RAPOR (Liste Ekleme)
        else if (result == 'historical_report') {
          AnalysisScreen.globalReports.insert(0, {
            'title': 'Manuel Oluşturulan Üretim Raporu',
            'date': '${now.day}.${now.month}.${now.year}',
            'type': 'PDF',
            'size': '1.2 MB',
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Rapor oluşturuldu ve "Analiz & Rapor" sekmesine eklendi.',
              ),
              backgroundColor: AppColors.neonBlue,
              duration: Duration(seconds: 2),
            ),
          );
        }
        // 8. DENETİM RAPORU (Liste Ekleme)
        else if (result == 'audit_report') {
          AnalysisScreen.globalReports.insert(0, {
            'title': 'Enerji Verimlilik ve Denetim Raporu',
            'date': '${now.day}.${now.month}.${now.year}',
            'type': 'PDF',
            'size': '2.8 MB',
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Denetim raporu oluşturuldu ve "Analiz & Rapor" sekmesine eklendi.',
              ),
              backgroundColor: AppColors.neonRed,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$title: ${result.toUpperCase()} seçeneği tıklandı.',
              ),
            ),
          );
        }
      },
      color: AppColors.cardGradientStart.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      itemBuilder: (BuildContext context) => menuItems,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.0),
        child: Icon(Icons.more_horiz, color: Colors.white38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              _buildPopupMenu(context),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.trending_up, color: color, size: 16),
              const SizedBox(width: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 2. AI ÖNERİ KARTI - GÜNCELLENDİ (API Bağlantısı)
class AIRecommendationCard extends StatefulWidget {
  const AIRecommendationCard({super.key});

  @override
  State<AIRecommendationCard> createState() => _AIRecommendationCardState();
}

class _AIRecommendationCardState extends State<AIRecommendationCard> {
  Map<String, dynamic>? aiData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAiData();
  }

  Future<void> _fetchAiData() async {
    try {
      final data = await ApiService().getAiRecommendation();
      if (mounted) {
        setState(() {
          aiData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          // Hata durumunda sessizce varsayılanı gösterebilir veya boş bırakabiliriz
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const GlassContainer(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.neonBlue),
        ),
      );
    }

    if (aiData == null) {
      return const GlassContainer(
        padding: EdgeInsets.all(24.0),
        child: Text(
          "AI Önerisi şu an alınamıyor.",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(24.0),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.neonBlue.withValues(alpha: 0.15),
          AppColors.cardGradientEnd,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.neonBlue),
              const SizedBox(width: 10),
              Text(
                aiData!['title'] ?? "AI Optimizasyon",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            aiData!['message'] ?? "",
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 10),
          // Eğer API'den 'estimated_gain' geliyorsa göster
          if (aiData!['estimated_gain'] != null)
            Text(
              "Tahmini Kazanç: ₺${aiData!['estimated_gain']}",
              style: const TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonBlue,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Öneriyi Uygula",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. GRAFİK BÖLÜMÜ - GÜNCELLENDİ (API Bağlantısı)
class ProductionChartSection extends StatefulWidget {
  const ProductionChartSection({super.key});

  @override
  State<ProductionChartSection> createState() => _ProductionChartSectionState();
}

class _ProductionChartSectionState extends State<ProductionChartSection> {
  TimePeriod _selectedPeriod = TimePeriod.daily;
  List<dynamic> _chartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    // Sadece Günlük için API yazdık, diğerleri için şimdilik mock veya boş dönebiliriz.
    if (_selectedPeriod == TimePeriod.daily) {
      try {
        final data = await ApiService().getDailyProductionChart();
        if (mounted) {
          setState(() {
            _chartData = data;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Mock veriler (Haftalık/Aylık için placeholder)
      if (mounted) {
        setState(() {
          _chartData =
              _selectedPeriod == TimePeriod.weekly
                  ? [
                    {'label': "Pzt", 'height': 0.6, 'is_high': true},
                    {'label': "Sal", 'height': 0.7, 'is_high': true},
                    {'label': "Çar", 'height': 0.8, 'is_high': true},
                    {'label': "Per", 'height': 0.5, 'is_high': false},
                    {'label': "Cum", 'height': 0.9, 'is_high': true},
                    {'label': "Cmt", 'height': 0.7, 'is_high': true},
                    {'label': "Paz", 'height': 0.6, 'is_high': true},
                  ]
                  : [
                    {'label': "H1", 'height': 0.7, 'is_high': true},
                    {'label': "H2", 'height': 0.8, 'is_high': true},
                    {'label': "H3", 'height': 0.6, 'is_high': true},
                    {'label': "H4", 'height': 0.9, 'is_high': true},
                  ];
          _isLoading = false;
        });
      }
    }
  }

  String _getTitle() {
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        return "Enerji Akışı (Son 24s)";
      case TimePeriod.weekly:
        return "Enerji Akışı (Son 7 Gün)";
      case TimePeriod.monthly:
        return "Enerji Akışı (Son 4 Hafta)";
    }
  }

  Widget _buildFilterButton(TimePeriod period, String label) {
    bool isSelected = _selectedPeriod == period;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
          _isLoading = true;
        });
        _loadChartData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.neonBlue.withValues(alpha: 0.2)
                  : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.neonBlue : Colors.white24,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.neonBlue : Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTitle(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildFilterButton(TimePeriod.daily, "Günlük"),
                  const SizedBox(width: 8),
                  _buildFilterButton(TimePeriod.weekly, "Haftalık"),
                  const SizedBox(width: 8),
                  _buildFilterButton(TimePeriod.monthly, "Aylık"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          _isLoading
              ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
              : SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:
                      _chartData.map((data) {
                        // API'den gelen field isimleri snake_case olabilir (örn: is_high)
                        // Dart map yapımıza göre kontrol ediyoruz.
                        final heightVal = (data['height'] as num).toDouble();
                        final labelVal = data['label'] as String;
                        // Python tarafında 'is_high', Dart tarafında 'isHigh' kullanmış olabiliriz.
                        // İkisini de kontrol edelim:
                        final isHighVal =
                            data['is_high'] ?? data['isHigh'] ?? false;

                        return _buildBar(
                          height: heightVal,
                          label: labelVal,
                          isHigh: isHighVal,
                        );
                      }).toList(),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required double height,
    required String label,
    bool isHigh = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 150 * height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors:
                  isHigh
                      ? [
                        AppColors.neonGreen.withValues(alpha: 0.3),
                        AppColors.neonGreen,
                      ]
                      : [Colors.white10, Colors.white24],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }
}

// 4. LOG LİSTE ELEMANI - DEĞİŞMEDİ
class LogListItem extends StatelessWidget {
  final String time;
  final String message;
  final String type;
  final String amount;

  const LogListItem({
    super.key,
    required this.time,
    required this.message,
    required this.type,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor = Colors.white;
    IconData typeIcon = Icons.info;

    switch (type) {
      case 'AI':
        typeColor = AppColors.neonBlue;
        typeIcon = Icons.auto_awesome;
        break;
      case 'WARN':
        typeColor = AppColors.neonRed;
        typeIcon = Icons.warning_amber_rounded;
        break;
      case 'SELL':
        typeColor = AppColors.neonGreen;
        typeIcon = Icons.attach_money;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardGradientStart,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// 5. HEADER (Merhaba Ahmet Bey kısmı) - DEĞİŞMEDİ
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Servisten okunmamış sayısını al
    final unreadCount = NotificationService().getUnreadNotifications().length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Merhaba, Ahmet Bey",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text(
                  "Ev Enerji Durumu",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "AKTİF",
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Bildirim Butonu (Stack ile Rozet Eklendi)
        InkWell(
          onTap: () {
            // Dashboard'dan tıklandığı için SADECE OKUNMAMIŞLARI göster
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => const NotificationScreen(showOnlyUnread: true),
              ),
            ).then((_) {
              // Geri dönüldüğünde (okundu yapıldıysa) rebuild için (basit çözüm)
              // Gerçekte state management gerektirir
            });
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),

                // Eğer okunmamış bildirim varsa Kırmızı Nokta göster
                if (unreadCount > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.neonRed,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 6. ÜRETİM TAHMİN DİYALOĞU - DEĞİŞMEDİ

// 6. ÜRETİM TAHMİN DİYALOĞU - YENİ (API Bağlantılı)
class ProductionForecastDialog extends StatefulWidget {
  const ProductionForecastDialog({super.key});

  @override
  State<ProductionForecastDialog> createState() =>
      _ProductionForecastDialogState();
}

class _ProductionForecastDialogState extends State<ProductionForecastDialog> {
  List<dynamic>? _forecastData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchForecast();
  }

  Future<void> _fetchForecast() async {
    try {
      final data = await ApiService().getDetailedForecast();
      if (mounted) {
        setState(() {
          _forecastData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Hata durumunda boş liste dönebiliriz.
        });
        // Kullanıcıya hata bildirimi gösterilebilir.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tahmin yüklenirken hata oluştu: $e"),
            backgroundColor: AppColors.neonRed,
          ),
        );
      }
    }
  }

  // İkon metin ismini, Material Design ikonuna çeviren yardımcı fonksiyon
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'wb_cloudy':
        return Icons.wb_cloudy;
      case 'nights_stay':
        return Icons.nights_stay;
      default:
        return Icons.power_settings_new; // Varsayılan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "24 Saatlik Üretim Tahmini",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "ML Modeli: Tahmin Edilen Veriler",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),

            // Tablo Başlıkları
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Saat/Hava",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Beklenen",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Verim",
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),

            // Yükleniyor veya Veri Listesi
            _isLoading
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(color: AppColors.neonBlue),
                  ),
                )
                : (_forecastData?.isEmpty ?? true)
                ? const SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      "Veri Alınamadı veya Model Yüklenmedi.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
                : SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: _forecastData!.length,
                    itemBuilder: (context, index) {
                      final item = _forecastData![index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Icon(
                                    _getIconData(
                                      item['iconName'],
                                    ), // API'den gelen metin ikon
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item['time'],
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                item['value'],
                                style: const TextStyle(
                                  color: AppColors.neonGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                item['efficiency'],
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.bar_chart,
                  color: AppColors.neonBlue,
                  size: 18,
                ),
                label: const Text(
                  "Detaylı Grafikleri Gör",
                  style: TextStyle(color: AppColors.neonBlue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 7. TÜKETİM DAĞILIMI DİYALOĞU - DEĞİŞMEDİ
class ConsumptionDistributionDialog extends StatelessWidget {
  const ConsumptionDistributionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> devices = [
      {
        'name': 'Salon Kliması',
        'consumption': '1.2 kW',
        'isActive': true,
        'icon': Icons.ac_unit,
      },
      {
        'name': 'Buzdolabı',
        'consumption': '0.15 kW',
        'isActive': true,
        'icon': Icons.kitchen,
      },
      {
        'name': 'TV Ünitesi',
        'consumption': '0.4 kW',
        'isActive': true,
        'icon': Icons.tv,
      },
      {
        'name': 'Aydınlatma (Tüm Ev)',
        'consumption': '0.05 kW',
        'isActive': true,
        'icon': Icons.lightbulb,
      },
      {
        'name': 'Çamaşır Makinesi',
        'consumption': '0.0 kW',
        'isActive': false,
        'icon': Icons.local_laundry_service,
      },
      {
        'name': 'Bulaşık Makinesi',
        'consumption': '0.0 kW',
        'isActive': false,
        'icon': Icons.local_dining,
      },
      {
        'name': 'Elektrikli Süpürge',
        'consumption': '0.0 kW',
        'isActive': false,
        'icon': Icons.cleaning_services,
      },
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Anlık Tüketim Dağılımı",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Aktif Cihazlar ve Tüketim",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),

            SizedBox(
              height: 350,
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final bool isActive = device['isActive'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? AppColors.neonRed.withValues(alpha: 0.2)
                                    : Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            device['icon'],
                            color:
                                isActive ? AppColors.neonRed : Colors.white38,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device['name'],
                                style: TextStyle(
                                  color:
                                      isActive ? Colors.white : Colors.white54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isActive ? "Aktif" : "Kapalı",
                                style: TextStyle(
                                  color:
                                      isActive
                                          ? AppColors.neonGreen
                                          : Colors.white38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          device['consumption'],
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.white38,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            const Divider(color: Colors.white10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Kapat",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
