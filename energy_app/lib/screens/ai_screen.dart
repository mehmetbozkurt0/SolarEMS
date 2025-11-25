import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/api_service.dart';
import '../widgets/glass_container.dart';

class AIOptimizationScreen extends StatefulWidget {
  const AIOptimizationScreen({super.key});

  @override
  State<AIOptimizationScreen> createState() => _AIOptimizationScreenState();
}

class _AIOptimizationScreenState extends State<AIOptimizationScreen> {
  bool _isLoading = false;

  Future<void> _applySuggestion(BuildContext context) async {
    setState(() => _isLoading = true);
    final success = await ApiService().applyRecommendation();

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '✅ Öneri başarıyla sisteme uygulandı!'
            : '❌ Bir hata oluştu, tekrar deneyin.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // ÖNEMLİ
      body: Stack(
        children: [
          /// Arka plan (MainLayout'ın shapes'i zaten var)
          Positioned.fill(
            child: Container(color: Colors.transparent),
          ),

          /// İçerik (PADDING KALDIRILDI!)
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Yapay Zeka Asistanı",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.cloud, color: Colors.white60),
                        SizedBox(width: 8),
                        Text(
                          "Manisa: 24°C, Parçalı Bulutlu",
                          style: TextStyle(color: Colors.white60),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 20),

                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonBlue.withOpacity(0.2),
                      AppColors.background.withOpacity(0.3),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 50, color: AppColors.neonBlue),
                      const SizedBox(height: 15),
                      const Text(
                        "Batarya Depolama Modu Öneriliyor",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Yarın öğleden sonra %80 olasılıkla yoğun yağış bekleniyor. Bugün üretilen enerjiyi satmak yerine bataryada depolayarak yarınki şebeke tüketimini minimize edebilirsiniz.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton.icon(
                        onPressed:
                            _isLoading ? null : () => _applySuggestion(context),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(
                          _isLoading
                              ? "Uygulanıyor..."
                              : "Öneriyi Uygula (Tahmini Kazanç: ₺18.50)",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonBlue,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "24 Saatlik Üretim Tahmini (ML Model)",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildForecastCard("14:00", Icons.wb_sunny, "Yüksek",
                          AppColors.neonGreen),
                      _buildForecastCard("15:00", Icons.wb_sunny, "Yüksek",
                          AppColors.neonGreen),
                      _buildForecastCard(
                          "16:00", Icons.wb_cloudy, "Orta", Colors.orange),
                      _buildForecastCard(
                          "17:00", Icons.cloud, "Düşük", Colors.grey),
                      _buildForecastCard("18:00", Icons.nights_stay, "Yok",
                          Colors.blueGrey),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Sistem Sağlığı & Anomaliler",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.neonRed.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.warning, color: AppColors.neonRed),
                      ),
                      const SizedBox(width: 15),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Panel Verim Düşüklüğü",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "3. Panel grubunda beklenen üretimden %15 sapma var. Gölgelenme veya tozlanma olabilir.",
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      const Icon(Icons.chevron_right,
                          color: Colors.white38),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(
      String time, IconData icon, String label, Color color) {
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
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
