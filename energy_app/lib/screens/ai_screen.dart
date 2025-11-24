import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';

class AIOptimizationScreen extends StatelessWidget {
  const AIOptimizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BAŞLIK VE HAVA DURUMU
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Yapay Zeka Asistanı", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(Icons.cloud, color: Colors.white60),
                  SizedBox(width: 8),
                  Text("Manisa: 24°C, Parçalı Bulutlu", style: TextStyle(color: Colors.white60)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),

          // ANA TAVSİYE KARTI (Hero Section)
          GlassContainer(
            gradient: LinearGradient(colors: [AppColors.neonBlue.withOpacity(0.2), AppColors.background]),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome, size: 50, color: AppColors.neonBlue),
                const SizedBox(height: 15),
                const Text("Batarya Depolama Modu Öneriliyor", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  "Yarın öğleden sonra %80 olasılıkla yoğun yağış bekleniyor. Bugün üretilen enerjiyi satmak yerine bataryada depolayarak yarınki şebeke tüketimini minimize edebilirsiniz.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check),
                  label: const Text("Öneriyi Uygula (Tahmini Kazanç: ₺18.50)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonBlue,
                    foregroundColor: Colors.black,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 24 SAATLİK TAHMİN LİSTESİ
          const Text("24 Saatlik Üretim Tahmini (ML Model)", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildForecastCard("14:00", Icons.wb_sunny, "Yüksek", AppColors.neonGreen),
                _buildForecastCard("15:00", Icons.wb_sunny, "Yüksek", AppColors.neonGreen),
                _buildForecastCard("16:00", Icons.wb_cloudy, "Orta", Colors.orange),
                _buildForecastCard("17:00", Icons.cloud, "Düşük", Colors.grey),
                _buildForecastCard("18:00", Icons.nights_stay, "Yok", Colors.blueGrey),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ANOMALİ TESPİTİ (İŞL.11)
          const Text("Sistem Sağlığı & Anomaliler", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.neonRed.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.warning, color: AppColors.neonRed),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Panel Verim Düşüklüğü", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("3. Panel grubunda beklenen üretimden %15 sapma var. Gölgelenme veya tozlanma olabilir.", style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildForecastCard(String time, IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 15.0),
      child: GlassContainer(
        width: 100,
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(time, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 10),
            Icon(icon, color: color),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}