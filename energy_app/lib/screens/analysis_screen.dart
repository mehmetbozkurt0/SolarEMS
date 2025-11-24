import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Enerji Analizi & Raporlama", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // TARİH SEÇİCİ VE FİLTRELER
          Row(
            children: [
              _buildFilterButton("Günlük", true),
              const SizedBox(width: 10),
              _buildFilterButton("Haftalık", false),
              const SizedBox(width: 10),
              _buildFilterButton("Aylık", false),
            ],
          ),
          const SizedBox(height: 30),

          // İSTATİSTİK GRID YAPISI
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildStatCard("Toplam Üretim", "124 kWh", Icons.wb_sunny, AppColors.neonGreen)),
                const SizedBox(width: 20),
                Expanded(child: _buildStatCard("Toplam Tüketim", "86 kWh", Icons.home, AppColors.neonRed)),
                const SizedBox(width: 20),
                Expanded(child: _buildStatCard("Net Kazanç", "₺420.50", Icons.account_balance_wallet, AppColors.neonBlue)),
              ],
            )
          else
            Column(
              children: [
                _buildStatCard("Toplam Üretim", "124 kWh", Icons.wb_sunny, AppColors.neonGreen),
                const SizedBox(height: 15),
                _buildStatCard("Toplam Tüketim", "86 kWh", Icons.home, AppColors.neonRed),
                const SizedBox(height: 15),
                _buildStatCard("Net Kazanç", "₺420.50", Icons.account_balance_wallet, AppColors.neonBlue),
              ],
            ),

          const SizedBox(height: 30),

          // DETAYLI GRAFİK (Mockup)
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Üretim vs Tüketim Dengesi", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Container(
                  height: 300,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Basit Grafik Çubukları (Üretim: Yeşil, Tüketim: Kırmızı)
                      _buildDoubleBar(0.4, 0.3, "Pzt"),
                      _buildDoubleBar(0.6, 0.4, "Sal"),
                      _buildDoubleBar(0.8, 0.5, "Çar"),
                      _buildDoubleBar(0.5, 0.7, "Per"), // Tüketim fazla
                      _buildDoubleBar(0.7, 0.4, "Cum"),
                      _buildDoubleBar(0.9, 0.3, "Cmt"),
                      _buildDoubleBar(0.8, 0.4, "Paz"),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 10, color: AppColors.neonGreen), SizedBox(width: 5),
                    Text("Üretim", style: TextStyle(color: Colors.white54)),
                    SizedBox(width: 20),
                    Icon(Icons.circle, size: 10, color: AppColors.neonRed), SizedBox(width: 5),
                    Text("Tüketim", style: TextStyle(color: Colors.white54)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          // SOSYAL ETKİ & ROZETLER (İŞL.09 & İŞL.07)
          const Text("Çevresel Etki & Başarılar", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.forest, color: AppColors.neonGreen, size: 40),
                const SizedBox(width: 20),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Karbon Ayak İzi", style: TextStyle(color: Colors.white60)),
                      Text("Bu ay 12 Ağaç Kurtardınız! 🌳", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                  child: const Text("Rozetleri Gör >", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.neonBlue : Colors.transparent,
        border: Border.all(color: isSelected ? AppColors.neonBlue : Colors.white24),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 5),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          )
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
            Container(width: 10, height: 150 * prodHeight, color: AppColors.neonGreen.withOpacity(0.8)),
            const SizedBox(width: 4),
            Container(width: 10, height: 150 * consHeight, color: AppColors.neonRed.withOpacity(0.8)),
          ],
        ),
        const SizedBox(height: 10),
        Text(day, style: const TextStyle(color: Colors.white38)),
      ],
    );
  }
}