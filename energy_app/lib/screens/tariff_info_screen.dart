import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';

class TariffInfoScreen extends StatelessWidget {
  const TariffInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    // Şu anki saati ondalık formata çevir (örn: 14:30 -> 14.5)
    final currentHour = now.hour + (now.minute / 60.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tarife Bilgileri",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BİLGİ KARTI
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.neonBlue,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Aktif Tarife: Üç Zamanlı Mesken",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Fiyatlar EPDK güncel birim fiyatlarına göre simüle edilmiştir. (Vergiler Dahil)",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Tarife Detayları",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // T1: GÜNDÜZ (06:00 - 17:00)
            _buildTariffCard(
              title: "Gündüz (T1)",
              timeRange: "06:00 - 17:00",
              buyPrice: "2.45 ₺",
              sellPrice: "2.10 ₺",
              color: Colors.orange,
              icon: Icons.wb_sunny,
              isActive: currentHour >= 6 && currentHour < 17,
            ),
            const SizedBox(height: 15),

            // T2: PUANT (17:00 - 22:00) - En Pahalı
            _buildTariffCard(
              title: "Puant (T2)",
              timeRange: "17:00 - 22:00",
              buyPrice: "3.85 ₺",
              sellPrice: "3.50 ₺",
              color: AppColors.neonRed,
              icon: Icons.warning_amber_rounded,
              isActive: currentHour >= 17 && currentHour < 22,
              isExpensive: true, // Vurgulu gösterim
            ),
            const SizedBox(height: 15),

            // T3: GECE (22:00 - 06:00) - En Ucuz
            _buildTariffCard(
              title: "Gece (T3)",
              timeRange: "22:00 - 06:00",
              buyPrice: "1.35 ₺",
              sellPrice: "1.10 ₺",
              color:
                  AppColors
                      .neonGreen, // Yeşil yerine ay ışığı rengi de olabilir ama ucuz olduğu için yeşil mantıklı
              icon: Icons.nights_stay,
              isActive: currentHour >= 22 || currentHour < 6,
              isCheap: true, // Vurgulu gösterim
            ),

            const SizedBox(height: 30),

            // İPUCU KARTI
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.neonBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: AppColors.neonBlue),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "İpucu: Bataryalarınızı 'Gece' tarifesinde şarj edip, 'Puant' saatlerinde kullanarak tasarruf edebilirsiniz.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTariffCard({
    required String title,
    required String timeRange,
    required String buyPrice,
    required String sellPrice,
    required Color color,
    required IconData icon,
    required bool isActive,
    bool isExpensive = false,
    bool isCheap = false,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(0), // İç padding'i özel ayarlayacağız
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // Aktif tarife ise kenarlık rengiyle vurgula
          border: isActive ? Border.all(color: color, width: 2) : null,
          color: isActive ? color.withOpacity(0.05) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ÜST KISIM: Başlık ve Saat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      timeRange,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // AKTİFSE "ŞU AN GEÇERLİ" ETİKETİ
              if (isActive) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "ŞU AN GEÇERLİ",
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
              const SizedBox(height: 10),

              // ALT KISIM: Fiyatlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ALIŞ FİYATI
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Alış Fiyatı (Tüketim)",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            buyPrice,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            " /kWh",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // SATIŞ FİYATI
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "Satış Fiyatı (Üretim)",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            sellPrice,
                            style: TextStyle(
                              color: AppColors.neonGreen,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            " /kWh",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
