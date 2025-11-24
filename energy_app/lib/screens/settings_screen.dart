import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';
import 'device_management_screen.dart'; // Cihaz Yönetimi ekranı
import 'notification_screen.dart'; // Bildirim ekranı
import 'tariff_info_screen.dart'; // YENİ: Tarife ekranı import edildi

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ayarlar & Profil",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // PROFİL KARTI
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 20),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ahmet Yılmaz",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "ahmet@email.com",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, color: AppColors.neonBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // AYAR LİSTESİ

          // 1. BİLDİRİMLER
          _buildSettingsTile(
            context,
            Icons.notifications,
            "Bildirimler",
            "Geçmiş bildirimler ve uyarılar",
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const NotificationScreen(showOnlyUnread: false),
                ),
              );
            },
          ),
          const SizedBox(height: 15),

          // 2. TARİFE BİLGİLERİ (GÜNCELLENDİ)
          _buildSettingsTile(
            context,
            Icons.attach_money,
            "Tarife Bilgileri",
            "Aktif tarife: Üç Zamanlı Mesken",
            false,
            onTap: () {
              // Yeni tarife ekranına yönlendirme
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TariffInfoScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 15),

          // 3. CİHAZ YÖNETİMİ
          _buildSettingsTile(
            context,
            Icons.devices,
            "Cihaz Yönetimi",
            "İnverter ve Batarya bağlantıları",
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeviceManagementScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 15),
          _buildSettingsTile(
            context,
            Icons.lock,
            "Gizlilik & Güvenlik",
            "Şifre ve 2FA ayarları",
            false,
          ),
          const SizedBox(height: 15),
          _buildSettingsTile(
            context,
            Icons.help,
            "Yardım & Destek",
            "SSS ve Müşteri Hizmetleri",
            false,
          ),

          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Çıkış Yap",
                style: TextStyle(color: AppColors.neonRed),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Settings Tile
  Widget _buildSettingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool hasSwitch, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: hasSwitch ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (hasSwitch)
              Switch(
                value: true,
                onChanged: (val) {},
                activeColor: AppColors.neonGreen,
                activeTrackColor: AppColors.neonGreen.withOpacity(0.3),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
