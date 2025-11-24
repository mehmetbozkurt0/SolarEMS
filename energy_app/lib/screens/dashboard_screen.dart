import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜST KISIM (Header)
          const HeaderSection(),
          const SizedBox(height: 30),

          // KARTLAR (Responsive) - EnergyCardType eklendi
          if (isDesktop)
            const Row(
              children: [
                Expanded(
                  child: EnergyStatusCard(
                    title: "Anlık Üretim",
                    value: "4.2 kW",
                    icon: Icons.wb_sunny_rounded,
                    color: AppColors.neonGreen,
                    subtitle: "+%12 verim artışı",
                    cardType: EnergyCardType.production, // Yeni
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: EnergyStatusCard(
                    title: "Anlık Tüketim",
                    value: "1.8 kW",
                    icon: Icons.home_filled,
                    color: AppColors.neonRed,
                    subtitle: "Klima aktif",
                    cardType: EnergyCardType.consumption, // Yeni
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: EnergyStatusCard(
                    title: "Şebeke Satış",
                    value: "2.4 kW",
                    icon: Icons.bolt,
                    color: AppColors.neonBlue,
                    subtitle: "₺42.50 Günlük Kazanç",
                    cardType: EnergyCardType.gridSale, // Yeni
                  ),
                ),
              ],
            )
          else
            const Column(
              children: [
                EnergyStatusCard(
                  title: "Anlık Üretim",
                  value: "4.2 kW",
                  icon: Icons.wb_sunny_rounded,
                  color: AppColors.neonGreen,
                  subtitle: "+%12 verim artışı",
                  cardType: EnergyCardType.production, // Yeni
                ),
                SizedBox(height: 16),
                EnergyStatusCard(
                  title: "Anlık Tüketim",
                  value: "1.8 kW",
                  icon: Icons.home_filled,
                  color: AppColors.neonRed,
                  subtitle: "Klima aktif",
                  cardType: EnergyCardType.consumption, // Yeni
                ),
                SizedBox(height: 16),
                EnergyStatusCard(
                  title: "Şebeke Satış",
                  value: "2.4 kW",
                  icon: Icons.bolt,
                  color: AppColors.neonBlue,
                  subtitle: "₺42.50 Günlük Kazanç",
                  cardType: EnergyCardType.gridSale, // Yeni
                ),
              ],
            ),

          const SizedBox(height: 30),

          // GRAFİK VE AI BÖLÜMÜ
          LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: ProductionChartSection()),
                    SizedBox(width: 20),
                    Expanded(flex: 1, child: AIRecommendationCard()),
                  ],
                );
              } else {
                return const Column(
                  children: [
                    ProductionChartSection(),
                    SizedBox(height: 20),
                    AIRecommendationCard(),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 30),

          // LİSTE (Son İşlemler)
          const Text(
            "Sistem Kayıtları",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const LogListItem(
            time: "14:30",
            message: "Batarya şarjı başlatıldı (Optimizasyon)",
            type: "AI",
            amount: "+2.0 kW",
          ),
          const LogListItem(
            time: "13:15",
            message: "Yüksek tüketim uyarısı: Fırın",
            type: "WARN",
            amount: "-3.5 kW",
          ),
          const LogListItem(
            time: "12:00",
            message: "Puant saat satış işlemi",
            type: "SELL",
            amount: "+4.1 kW",
          ),
        ],
      ),
    );
  }
}
