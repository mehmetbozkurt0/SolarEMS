import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'glass_container.dart'; // GlassContainer dosyanın widgets klasöründe olduğunu varsayıyorum

// 1. ÖZET KARTLARI (EnergyStatusCard)
class EnergyStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const EnergyStatusCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

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
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Icon(Icons.more_horiz, color: Colors.white38),
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
          AppColors.neonBlue.withOpacity(0.15),
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

// Yeni: Zaman Periyodu Enum'u
enum TimePeriod { daily, weekly, monthly }

// 3. GRAFİK BÖLÜMÜ (Stateful Widget olarak güncellendi)
class ProductionChartSection extends StatefulWidget {
  const ProductionChartSection({super.key});

  @override
  State<ProductionChartSection> createState() => _ProductionChartSectionState();
}

class _ProductionChartSectionState extends State<ProductionChartSection> {
  // Varsayılan olarak günlük seçili
  TimePeriod _selectedPeriod = TimePeriod.daily;

  // Mock data yapısı: {label: String, height: double (0.0 - 1.0), isHigh: bool}
  List<Map<String, dynamic>> _getChartData() {
    switch (_selectedPeriod) {
      case TimePeriod.daily:
        // Saatlik Veri (Son 24s)
        return [
          {'label': "00:00", 'height': 0.4, 'isHigh': false},
          {'label': "04:00", 'height': 0.3, 'isHigh': false},
          {'label': "08:00", 'height': 0.6, 'isHigh': true},
          {'label': "12:00", 'height': 0.9, 'isHigh': true},
          {'label': "16:00", 'height': 0.7, 'isHigh': true},
          {'label': "20:00", 'height': 0.5, 'isHigh': false},
          {'label': "23:59", 'height': 0.4, 'isHigh': false},
        ];
      case TimePeriod.weekly:
        // Günlük Veri (Son 7 Gün)
        return [
          {'label': "Pzt", 'height': 0.6, 'isHigh': true},
          {'label': "Sal", 'height': 0.7, 'isHigh': true},
          {'label': "Çar", 'height': 0.8, 'isHigh': true},
          {'label': "Per", 'height': 0.5, 'isHigh': false},
          {'label': "Cum", 'height': 0.9, 'isHigh': true},
          {'label': "Cmt", 'height': 0.7, 'isHigh': true},
          {'label': "Paz", 'height': 0.6, 'isHigh': true},
        ];
      case TimePeriod.monthly:
        // Haftalık Veri (Son 4 Hafta)
        return [
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
                  ? AppColors.neonBlue.withOpacity(0.2)
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
                      height: data['height'],
                      label: data['label'],
                      isHigh: data['isHigh'],
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
    // Existing _buildBar logic remains the same.
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
                        AppColors.neonGreen.withOpacity(0.3),
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
              color: typeColor.withOpacity(0.1),
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
                    color: AppColors.neonGreen.withOpacity(0.2),
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
