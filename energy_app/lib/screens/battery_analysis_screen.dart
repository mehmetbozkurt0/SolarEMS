import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';

class BatteryAnalysisScreen extends StatefulWidget {
  const BatteryAnalysisScreen({super.key});

  @override
  State<BatteryAnalysisScreen> createState() => _BatteryAnalysisScreenState();
}

class _BatteryAnalysisScreenState extends State<BatteryAnalysisScreen> {
  // Mock Batarya Verileri
  final List<Map<String, dynamic>> _batteries = [
    {
      'id': 'bat-001',
      'name': 'Ana Depolama (Tesla Powerwall)',
      'chargeLevel': 0.78, // %78
      'isActive': true,
      'voltageLimit': 48.0, // Volt
      'maxChargeLimit': 90.0, // %
      'notifyLowBattery': true, // %20 altı bildirim
      'status': 'Discharging (-1.2 kW)',
      'temp': '24°C',
    },
    {
      'id': 'bat-002',
      'name': 'Yedek Ünite 1 (LG Chem)',
      'chargeLevel': 0.45, // %45
      'isActive': true,
      'voltageLimit': 48.0,
      'maxChargeLimit': 100.0,
      'notifyLowBattery': true,
      'status': 'Standby',
      'temp': '21°C',
    },
    {
      'id': 'bat-003',
      'name': 'Yedek Ünite 2 (Eski Tip)',
      'chargeLevel': 0.15, // %15 (Düşük!)
      'isActive': false,
      'voltageLimit': 24.0,
      'maxChargeLimit': 80.0,
      'notifyLowBattery': false,
      'status': 'Offline',
      'temp': '--',
    },
  ];

  // Ayar Güncelleme Simülasyonu
  void _updateBatterySetting(int index, String key, dynamic value) {
    setState(() {
      _batteries[index][key] = value;
    });

    // Eğer %20 altı bildirim açıldıysa kullanıcıya bilgi ver
    if (key == 'notifyLowBattery' && value == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${_batteries[index]['name']} için düşük şarj uyarısı açıldı.",
          ),
          backgroundColor: AppColors.neonBlue,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Batarya Yönetimi & Analiz",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _batteries.length,
        itemBuilder: (context, index) {
          final battery = _batteries[index];
          return _buildBatteryCard(battery, index);
        },
      ),
    );
  }

  Widget _buildBatteryCard(Map<String, dynamic> battery, int index) {
    // Renk belirleme (Şarj durumuna göre)
    Color statusColor = AppColors.neonGreen;
    if (battery['chargeLevel'] < 0.20)
      statusColor = AppColors.neonRed;
    else if (battery['chargeLevel'] < 0.50)
      statusColor = Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Kısım: İsim ve Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.battery_charging_full,
                        color: statusColor,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              battery['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${battery['status']} • ${battery['temp']}",
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: battery['isActive'],
                  activeColor: AppColors.neonGreen,
                  activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.3),
                  onChanged:
                      (val) => _updateBatterySetting(index, 'isActive', val),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Şarj Göstergesi (Progress Bar)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Doluluk: %${(battery['chargeLevel'] * 100).toInt()}",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (battery['chargeLevel'] < 0.20)
                  const Text(
                    "⚠️ Düşük Seviye",
                    style: TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: battery['chargeLevel'],
                backgroundColor: Colors.white10,
                color: statusColor,
                minHeight: 10,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),

            // --- YÖNETİM AYARLARI ---
            const Text(
              "Ayarlar & Sınırlar",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // 1. Voltaj Sınırı (Slider yerine +/- butonlu yapı veya Text)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Voltaj Sınırı (V)",
                  style: TextStyle(color: Colors.white54),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.white38,
                      ),
                      onPressed:
                          battery['isActive']
                              ? () {
                                _updateBatterySetting(
                                  index,
                                  'voltageLimit',
                                  battery['voltageLimit'] - 1,
                                );
                              }
                              : null,
                    ),
                    Text(
                      "${battery['voltageLimit']} V",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white38,
                      ),
                      onPressed:
                          battery['isActive']
                              ? () {
                                _updateBatterySetting(
                                  index,
                                  'voltageLimit',
                                  battery['voltageLimit'] + 1,
                                );
                              }
                              : null,
                    ),
                  ],
                ),
              ],
            ),

            // 2. Maksimum Şarj Limiti (Slider)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Maks. Şarj Limiti",
                      style: TextStyle(color: Colors.white54),
                    ),
                    Text(
                      "%${battery['maxChargeLimit'].toInt()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: battery['maxChargeLimit'],
                  min: 50,
                  max: 100,
                  divisions: 10,
                  activeColor: AppColors.neonBlue,
                  inactiveColor: Colors.white10,
                  onChanged:
                      battery['isActive']
                          ? (val) => _updateBatterySetting(
                            index,
                            'maxChargeLimit',
                            val,
                          )
                          : null,
                ),
              ],
            ),

            // 3. Düşük Şarj Bildirimi (<%20)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white54,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "%20 Altında Bildir",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
                Switch(
                  value: battery['notifyLowBattery'],
                  activeColor: AppColors.neonRed,
                  activeTrackColor: AppColors.neonRed.withValues(alpha: 0.3),
                  onChanged:
                      (val) =>
                          _updateBatterySetting(index, 'notifyLowBattery', val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
