import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';
import '../core/api_service.dart'; // ApiService'i ekle

// Analiz ve Raporlama ekranı için zaman periyodu enum'u
enum AnalysisTimePeriod { daily, weekly, monthly }

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  // MOCK Raporlar listesi (Diğer yerlerde manuel rapor oluşturmak için kullanılıyor)
  static List<Map<String, String>> globalReports = [
    {
      'title': 'Ekim 2023 Üretim Raporu',
      'date': '31.10.2023',
      'type': 'PDF',
      'size': '1.4 MB',
    },
    {
      'title': 'Eylül 2023 Performans',
      'date': '30.09.2023',
      'type': 'XLSX',
      'size': '2.1 MB',
    },
    {
      'title': 'Q3 2023 Enerji Özeti',
      'date': '30.09.2023',
      'type': 'PDF',
      'size': '3.5 MB',
    },
  ];

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  AnalysisTimePeriod _selectedPeriod = AnalysisTimePeriod.daily;

  // ML'den gelecek çevresel etki verisi
  Map<String, dynamic>? _environmentalData;
  bool _isDataLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEnvironmentalData();
  }

  Future<void> _fetchEnvironmentalData() async {
    try {
      final data = await ApiService().getEnvironmentalImpact();
      if (mounted) {
        setState(() {
          _environmentalData = data;
          _isDataLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDataLoading = false);
        // Hata durumunda bildirim gösterilebilir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Çevresel etki verisi alınamadı.")),
        );
      }
    }
  }

  // Rapor Oluşturma Simülasyonu
  void _generateReport() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.neonBlue),
          ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {
        final now = DateTime.now();
        AnalysisScreen.globalReports.insert(0, {
          'title': 'Anlık Üretim Raporu (${now.hour}:${now.minute})',
          'date': '${now.day}.${now.month}.${now.year}',
          'type': 'PDF',
          'size': '0.8 MB',
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rapor başarıyla oluşturuldu ve listeye eklendi."),
          backgroundColor: AppColors.neonGreen,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // --- MOCK DATA (ML API'sinde endpoint'i olmayan kısımlar) ---
  Map<String, List<String>> _getStatData() {
    switch (_selectedPeriod) {
      case AnalysisTimePeriod.daily:
        return {
          'Üretim': ["Toplam Üretim", "124 kWh", "+12% Günlük"],
          'Tüketim': ["Toplam Tüketim", "86 kWh", "-5% Günlük"],
          'Kazanç': ["Net Kazanç", "₺420.50", "₺150 Satış"],
        };
      case AnalysisTimePeriod.weekly:
        return {
          'Üretim': ["Toplam Üretim", "860 kWh", "+8% Haftalık"],
          'Tüketim': ["Toplam Tüketim", "540 kWh", "+10% Haftalık"],
          'Kazanç': ["Net Kazanç", "₺2,800.00", "₺950 Satış"],
        };
      case AnalysisTimePeriod.monthly:
        return {
          'Üretim': ["Toplam Üretim", "3.5 MWh", "-2% Aylık"],
          'Tüketim': ["Toplam Tüketim", "2.2 MWh", "-1% Aylık"],
          'Kazanç': ["Net Kazanç", "₺11,500.00", "₺3,800 Satış"],
        };
    }
  }

  List<Map<String, dynamic>> _getChartData() {
    // BU KISIM NORMALDE ML CORE'DAN GELMELİDİR (DailyProductionChart gibi)
    switch (_selectedPeriod) {
      case AnalysisTimePeriod.daily:
        return const [
          {'prod': 0.4, 'cons': 0.3, 'label': "0-4h"},
          {'prod': 0.6, 'cons': 0.4, 'label': "4-8h"},
          {'prod': 0.8, 'cons': 0.5, 'label': "8-12h"},
          {'prod': 0.5, 'cons': 0.7, 'label': "12-16h"},
          {'prod': 0.7, 'cons': 0.4, 'label': "16-20h"},
          {'prod': 0.9, 'cons': 0.3, 'label': "20-24h"},
        ];
      case AnalysisTimePeriod.weekly:
        return const [
          {'prod': 0.7, 'cons': 0.5, 'label': "Pzt"},
          {'prod': 0.8, 'cons': 0.4, 'label': "Sal"},
          {'prod': 0.5, 'cons': 0.7, 'label': "Çar"},
          {'prod': 0.9, 'cons': 0.6, 'label': "Per"},
          {'prod': 0.6, 'cons': 0.4, 'label': "Cum"},
          {'prod': 0.7, 'cons': 0.8, 'label': "Cmt"},
          {'prod': 0.8, 'cons': 0.5, 'label': "Paz"},
        ];
      case AnalysisTimePeriod.monthly:
        return const [
          {'prod': 0.8, 'cons': 0.6, 'label': "Haf 1"},
          {'prod': 0.7, 'cons': 0.5, 'label': "Haf 2"},
          {'prod': 0.9, 'cons': 0.7, 'label': "Haf 3"},
          {'prod': 0.6, 'cons': 0.4, 'label': "Haf 4"},
        ];
    }
  }

  Widget _buildFilterButton(AnalysisTimePeriod period, String text) {
    bool isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonBlue : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.neonBlue : Colors.white24,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoubleBar(double prodHeight, double consHeight, String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 10,
              height: 150 * prodHeight,
              color: AppColors.neonGreen.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: 150 * consHeight,
              color: AppColors.neonRed.withValues(alpha: 0.8),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(day, style: const TextStyle(color: Colors.white38)),
      ],
    );
  }

  Widget _buildReportItem(Map<String, String> report) {
    IconData fileIcon = Icons.insert_drive_file;
    Color fileColor = Colors.white;

    if (report['type'] == 'PDF') {
      fileIcon = Icons.picture_as_pdf;
      fileColor = Colors.redAccent;
    } else if (report['type'] == 'XLSX') {
      fileIcon = Icons.table_chart;
      fileColor = Colors.greenAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(fileIcon, color: fileColor, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${report['date']} • ${report['size']}",
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.neonBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${report['title']} indiriliyor...")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow(String title, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalCard() {
    if (_isDataLoading) {
      return GlassContainer(
        padding: const EdgeInsets.all(20),
        gradient: LinearGradient(
          colors: [
            AppColors.neonGreen.withOpacity(0.1),
            AppColors.cardGradientEnd,
          ],
        ),
        child: const Center(
          child: SizedBox(
            height: 50,
            child: CircularProgressIndicator(color: AppColors.neonGreen),
          ),
        ),
      );
    }

    final data = _environmentalData;
    final totalTrees = data?['kurtarilan_agac'] ?? 0.0;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.neonGreen.withValues(alpha: 0.15),
          AppColors.cardGradientEnd,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forest, color: AppColors.neonGreen, size: 40),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Önlenen CO₂ Salınımı",
                      style: TextStyle(color: Colors.white60),
                    ),
                    Text(
                      "Bu ay ${totalTrees.toStringAsFixed(0)} Ağaç Kurtardınız! 🌳",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Detaylar >",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildImpactRow(
            "Toplam Temiz Enerji Üretimi",
            "${data?['toplam_uretim_kwh']?.toStringAsFixed(2) ?? '0.00'} kWh",
            AppColors.neonGreen,
          ),
          _buildImpactRow(
            "Eşdeğer CO₂ Azalımı",
            "${data?['onlenen_co2_kg']?.toStringAsFixed(2) ?? '0.00'} kg",
            AppColors.neonGreen,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;
    final statData = _getStatData();
    final chartData = _getChartData();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Enerji Analizi & Raporlama",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Filtreler
          Row(
            children: [
              _buildFilterButton(AnalysisTimePeriod.daily, "Günlük"),
              const SizedBox(width: 10),
              _buildFilterButton(AnalysisTimePeriod.weekly, "Haftalık"),
              const SizedBox(width: 10),
              _buildFilterButton(AnalysisTimePeriod.monthly, "Aylık"),
            ],
          ),
          const SizedBox(height: 30),

          // İstatistikler (Mock)
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    statData['Üretim']![0],
                    statData['Üretim']![1],
                    Icons.wb_sunny,
                    AppColors.neonGreen,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    statData['Tüketim']![0],
                    statData['Tüketim']![1],
                    Icons.home,
                    AppColors.neonRed,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildStatCard(
                    statData['Kazanç']![0],
                    statData['Kazanç']![1],
                    Icons.account_balance_wallet,
                    AppColors.neonBlue,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildStatCard(
                  statData['Üretim']![0],
                  statData['Üretim']![1],
                  Icons.wb_sunny,
                  AppColors.neonGreen,
                ),
                const SizedBox(height: 15),
                _buildStatCard(
                  statData['Tüketim']![0],
                  statData['Tüketim']![1],
                  Icons.home,
                  AppColors.neonRed,
                ),
                const SizedBox(height: 15),
                _buildStatCard(
                  statData['Kazanç']![0],
                  statData['Kazanç']![1],
                  Icons.account_balance_wallet,
                  AppColors.neonBlue,
                ),
              ],
            ),

          const SizedBox(height: 30),

          // YENİ DİNAMİK ÇEVRESEL ETKİ KARTI
          _buildEnvironmentalCard(),
          const SizedBox(height: 30),

          // Grafik (Mock)
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Üretim vs Tüketim Dengesi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  height: 300,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        chartData.map((data) {
                          return _buildDoubleBar(
                            data['prod'] as double,
                            data['cons'] as double,
                            data['label'] as String,
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 10, color: AppColors.neonGreen),
                    SizedBox(width: 5),
                    Text("Üretim", style: TextStyle(color: Colors.white54)),
                    SizedBox(width: 20),
                    Icon(Icons.circle, size: 10, color: AppColors.neonRed),
                    SizedBox(width: 5),
                    Text("Tüketim", style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Raporlar (Mock)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Raporlarım",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.add, color: AppColors.neonBlue),
                label: const Text(
                  "Yeni Rapor Oluştur",
                  style: TextStyle(color: AppColors.neonBlue),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.neonBlue.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children:
                  AnalysisScreen.globalReports.isEmpty
                      ? [
                        const Text(
                          "Henüz rapor oluşturulmadı.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ]
                      : AnalysisScreen.globalReports
                          .map((report) => _buildReportItem(report))
                          .toList(),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
