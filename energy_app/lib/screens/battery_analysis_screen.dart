import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';
import '../core/api_service.dart'; // Eklendi

class BatteryAnalysisScreen extends StatefulWidget {
  const BatteryAnalysisScreen({super.key});

  @override
  State<BatteryAnalysisScreen> createState() => _BatteryAnalysisScreenState();
}

class _BatteryAnalysisScreenState extends State<BatteryAnalysisScreen> {
  List<dynamic> _batteries = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadBatteries();
  }

  Future<void> _loadBatteries() async {
    try {
      final data = await _apiService.getBatteries();
      if (mounted) {
        setState(() {
          _batteries = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Batarya yükleme hatası: $e");
    }
  }

  // Ayar Güncelleme (Backend API)
  Future<void> _updateBatterySetting(
    int index,
    String key,
    dynamic value,
  ) async {
    // Önce lokalde iyimser güncelleme (Optimistic UI Update)
    final originalValue = _batteries[index][key];
    setState(() {
      _batteries[index][key] = value;
    });

    final batteryId = _batteries[index]['id'];

    // API için gerekli settings objesini hazırla
    // Python modeline uygun: isActive, voltageLimit, maxChargeLimit, notifyLowBattery
    Map<String, dynamic> settings = {
      'isActive': _batteries[index]['isActive'],
      'voltageLimit': _batteries[index]['voltageLimit'],
      'maxChargeLimit': _batteries[index]['maxChargeLimit'],
      'notifyLowBattery': _batteries[index]['notifyLowBattery'],
    };

    try {
      await _apiService.updateBatterySettings(batteryId, settings);

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
    } catch (e) {
      // Hata olursa geri al
      setState(() {
        _batteries[index][key] = originalValue;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ayar güncellenemedi!")));
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
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
    double chargeLevel = (battery['chargeLevel'] as num).toDouble();
    Color statusColor = AppColors.neonGreen;
    if (chargeLevel < 0.20)
      statusColor = AppColors.neonRed;
    else if (chargeLevel < 0.50)
      statusColor = Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Kısım
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

            // Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Doluluk: %${(chargeLevel * 100).toInt()}",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (chargeLevel < 0.20)
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
                value: chargeLevel,
                backgroundColor: Colors.white10,
                color: statusColor,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),

            // Ayarlar
            const Text(
              "Ayarlar & Sınırlar",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Voltaj
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
                              ? () => _updateBatterySetting(
                                index,
                                'voltageLimit',
                                battery['voltageLimit'] - 1,
                              )
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
                              ? () => _updateBatterySetting(
                                index,
                                'voltageLimit',
                                battery['voltageLimit'] + 1,
                              )
                              : null,
                    ),
                  ],
                ),
              ],
            ),

            // Max Charge Limit Slider
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
                      "%${(battery['maxChargeLimit'] as num).toInt()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: (battery['maxChargeLimit'] as num).toDouble(),
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

            // Notification Switch
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
