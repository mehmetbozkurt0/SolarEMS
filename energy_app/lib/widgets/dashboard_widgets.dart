import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'glass_container.dart';
// Analiz ekranındaki rapor listesine erişmek için import edildi
import '../screens/analysis_screen.dart';

// Kart Tipi Enum'u (Menü içeriklerini belirlemek için)
enum EnergyCardType { production, consumption, gridSale }

// Zaman Periyodu Enum'u (Grafik ve filtreler için)
enum TimePeriod { daily, weekly, monthly }

// 1. ÖZET KARTLARI (EnergyStatusCard)
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

  // Fonksiyonel Gereksinimlere dayalı menüyü oluşturur
  Widget _buildPopupMenu(BuildContext context) {
    List<PopupMenuEntry<String>> menuItems;

    // İŞL.04: ML Tahmini, İŞL.11: Anomali (Backend), İŞL.03: Rapor
    if (cardType == EnergyCardType.production) {
      menuItems = const [
        PopupMenuItem(
          value: 'daily_forecast',
          child: Text(
            '24s Tahmini ve Verim (İŞL.04)',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'historical_report',
          child: Text(
            'Tarihsel Üretim Raporu (İŞL.03)',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ];
    }
    // İŞL.13: Rapor, İŞL.08: Kıyaslama
    else if (cardType == EnergyCardType.consumption) {
      menuItems = const [
        PopupMenuItem(
          value: 'consumption_distribution',
          child: Text(
            'Tüketim Dağılımı (Cihaz) (İŞL.13)',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'audit_report',
          child: Text(
            'Enerji Denetim Raporu (İŞL.13)',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'regional_comparison',
          child: Text(
            'Bölgesel Kıyaslama (İŞL.08)',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ];
    }
    // İŞL.02: Mahsuplaşma, İŞL.12: Optimizasyon Kazancı, İŞL.06: Batarya
    else if (cardType == EnergyCardType.gridSale) {
      menuItems = const [
        PopupMenuItem(
          value: 'net_metering',
          child: Text(
            'Tarife ve Mahsuplaşma Detayı (İŞL.02)',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'optimization_history',
          child: Text(
            'Optimizasyon Geçmişi (İŞL.12)',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        PopupMenuItem(
          value: 'battery_management',
          child: Text(
            'Batarya Şarj Yönetimi (İŞL.06)',
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
        // 3. TARİHSEL RAPOR OLUŞTURMA (Listeye Ekleme)
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
        // 4. ENERJİ DENETİM RAPORU OLUŞTURMA (İŞL.13 - Listeye Ekleme) -- YENİ EKLENDİ
        else if (result == 'audit_report') {
          AnalysisScreen.globalReports.insert(0, {
            'title': 'Enerji Verimlilik ve Denetim Raporu',
            'date': '${now.day}.${now.month}.${now.year}',
            'type': 'PDF',
            'size': '2.8 MB', // Daha detaylı olduğu için boyutu büyük
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Denetim raporu oluşturuldu ve "Analiz & Rapor" sekmesine eklendi.',
              ),
              backgroundColor: AppColors.neonRed, // Tüketim/Denetim vurgusu
              duration: Duration(seconds: 2),
            ),
          );
        }
        // DİĞER SEÇENEKLER (Henüz yapılmayanlar)
        else {
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

// 2. AI ÖNERİ KARTI
class AIRecommendationCard extends StatelessWidget {
  const AIRecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.neonBlue),
              SizedBox(width: 10),
              Text(
                "AI Optimizasyon",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Yarın hava bulutlu olacak. Bataryayı gece tarifesinde (02:00 - 05:00) tam kapasite şarj etmeniz önerilir.",
            style: TextStyle(color: Colors.white70, height: 1.5),
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

// 3. GRAFİK BÖLÜMÜ
class ProductionChartSection extends StatefulWidget {
  const ProductionChartSection({super.key});

  @override
  State<ProductionChartSection> createState() => _ProductionChartSectionState();
}

class _ProductionChartSectionState extends State<ProductionChartSection> {
  TimePeriod _selectedPeriod = TimePeriod.daily;

  List<Map<String, dynamic>> _getChartData() {
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        return const [
          {'label': "00:00", 'height': 0.4, 'isHigh': false},
          {'label': "04:00", 'height': 0.3, 'isHigh': false},
          {'label': "08:00", 'height': 0.6, 'isHigh': true},
          {'label': "12:00", 'height': 0.9, 'isHigh': true},
          {'label': "16:00", 'height': 0.7, 'isHigh': true},
          {'label': "20:00", 'height': 0.5, 'isHigh': false},
          {'label': "23:59", 'height': 0.4, 'isHigh': false},
        ];
      case TimePeriod.weekly:
        return const [
          {'label': "Pzt", 'height': 0.6, 'isHigh': true},
          {'label': "Sal", 'height': 0.7, 'isHigh': true},
          {'label': "Çar", 'height': 0.8, 'isHigh': true},
          {'label': "Per", 'height': 0.5, 'isHigh': false},
          {'label': "Cum", 'height': 0.9, 'isHigh': true},
          {'label': "Cmt", 'height': 0.7, 'isHigh': true},
          {'label': "Paz", 'height': 0.6, 'isHigh': true},
        ];
      case TimePeriod.monthly:
        return const [
          {'label': "Hafta 1", 'height': 0.7, 'isHigh': true},
          {'label': "Hafta 2", 'height': 0.8, 'isHigh': true},
          {'label': "Hafta 3", 'height': 0.6, 'isHigh': true},
          {'label': "Hafta 4", 'height': 0.9, 'isHigh': true},
        ];
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
        });
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
    final chartData = _getChartData();
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
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  chartData.map((data) {
                    return _buildBar(
                      height: data['height'] as double,
                      label: data['label'] as String,
                      isHigh: data['isHigh'] as bool,
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

// 4. LOG LİSTE ELEMANI
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

// 5. HEADER (Merhaba Ahmet Bey kısmı)
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
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
        const CircleAvatar(
          backgroundColor: Colors.white10,
          radius: 24,
          child: Icon(Icons.notifications_outlined, color: Colors.white),
        ),
      ],
    );
  }
}

// 6. ÜRETİM TAHMİN DİYALOĞU
class ProductionForecastDialog extends StatelessWidget {
  const ProductionForecastDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> forecastData = [
      {
        'time': '14:00',
        'value': '4.5 kW',
        'efficiency': '98%',
        'icon': Icons.wb_sunny,
      },
      {
        'time': '15:00',
        'value': '4.3 kW',
        'efficiency': '96%',
        'icon': Icons.wb_sunny,
      },
      {
        'time': '16:00',
        'value': '3.8 kW',
        'efficiency': '92%',
        'icon': Icons.wb_cloudy,
      },
      {
        'time': '17:00',
        'value': '2.5 kW',
        'efficiency': '85%',
        'icon': Icons.cloud,
      },
      {
        'time': '18:00',
        'value': '1.1 kW',
        'efficiency': '70%',
        'icon': Icons.wb_twilight,
      },
      {
        'time': '19:00',
        'value': '0.2 kW',
        'efficiency': '40%',
        'icon': Icons.nights_stay,
      },
      {
        'time': '20:00',
        'value': '0.0 kW',
        'efficiency': '0%',
        'icon': Icons.nights_stay,
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
                      "24 Saatlik Üretim Tahmini",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "ML Modeli: Güneşli, 24°C",
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
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),

            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: forecastData.length,
                itemBuilder: (context, index) {
                  final item = forecastData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Icon(
                                item['icon'],
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

// 7. TÜKETİM DAĞILIMI DİYALOĞU (İŞL.13)
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
