import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/notification_service.dart';
import '../widgets/glass_container.dart';

class NotificationScreen extends StatelessWidget {
  final bool
  showOnlyUnread; // Dashboard'dan gelirse true, Ayarlardan gelirse false

  const NotificationScreen({super.key, this.showOnlyUnread = false});

  @override
  Widget build(BuildContext context) {
    final notificationService = NotificationService();
    // İsteğe göre veriyi çekiyoruz
    final List<AppNotification> notifications =
        showOnlyUnread
            ? notificationService.getUnreadNotifications()
            : notificationService.getPastWeekNotifications();

    // Tarihe göre sırala (En yeni en üstte)
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          showOnlyUnread ? "Okunmamış Bildirimler" : "Bildirim Geçmişi (7 Gün)",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (showOnlyUnread && notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all, color: AppColors.neonBlue),
              tooltip: "Tümünü Okundu İşaretle",
              onPressed: () {
                notificationService.markAllAsRead();
                Navigator.pop(context); // Ekranı kapatıp yenilenmesini sağlar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Tüm bildirimler okundu olarak işaretlendi."),
                    backgroundColor: AppColors.neonGreen,
                  ),
                );
              },
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      body:
          notifications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 60,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Görüntülenecek bildirim yok.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final color = notificationService.getColorForType(
                    notification.type,
                  );
                  final icon = notificationService.getIconForType(
                    notification.type,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // İkon Kutusu
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: color.withOpacity(0.3)),
                            ),
                            child: Icon(icon, color: color, size: 24),
                          ),
                          const SizedBox(width: 16),

                          // İçerik
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (!notification.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.neonRed,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notification.message,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(notification.timestamp),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}.${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
