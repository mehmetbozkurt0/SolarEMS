import 'package:flutter/material.dart';
import 'constants.dart'; // AppColors için

// Bildirim Tipleri (Kategoriler)
enum NotificationType {
  critical, // Kırmızı: Arıza, Tehlike
  warning, // Turuncu: Düşük Batarya, Verim Düşüklüğü
  info, // Mavi: Hava Durumu, Tarife Bilgisi
  success, // Yeşil: Tasarruf Hedefi, Tam Şarj
}

// Bildirim Modeli
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

// Bildirim Servisi (Mock Data Havuzu)
class NotificationService {
  // Singleton yapısı (Uygulamanın her yerinden aynı listeye erişmek için)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Mock Bildirim Verileri
  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      title: 'Kritik İnverter Hatası',
      message: 'Ana inverter bağlantısı koptu. Lütfen cihazı kontrol edin.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      type: NotificationType.critical,
      isRead: false, // Okunmamış
    ),
    AppNotification(
      id: '2',
      title: 'Düşük Batarya Uyarısı',
      message: 'Tesla Powerwall şarjı %18 seviyesine indi.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.warning,
      isRead: false, // Okunmamış
    ),
    AppNotification(
      id: '3',
      title: 'Tam Kapasite Şarj',
      message: 'Bataryalarınız %100 doluluk oranına ulaştı.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.success,
      isRead: true, // Okunmuş
    ),
    AppNotification(
      id: '4',
      title: 'Hava Durumu Uyarısı',
      message: 'Yarın için yoğun bulut bekleniyor. Tüketimi optimize edin.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.info,
      isRead: true,
    ),
    AppNotification(
      id: '5',
      title: 'Haftalık Rapor Hazır',
      message: 'Geçen haftanın üretim raporu oluşturuldu.',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      type: NotificationType.info,
      isRead: true,
    ),
    // 1 haftadan eski veri (Test için - Filtreye takılmalı)
    AppNotification(
      id: '6',
      title: 'Eski Bildirim',
      message: 'Bu bildirim 8 gün öncesine ait.',
      timestamp: DateTime.now().subtract(const Duration(days: 8)),
      type: NotificationType.info,
      isRead: true,
    ),
  ];

  // 1. Dashboard İçin: Sadece Okunmamışlar
  List<AppNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // 2. Ayarlar İçin: Son 1 Haftanın Tümü
  List<AppNotification> getPastWeekNotifications() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications
        .where((n) => n.timestamp.isAfter(oneWeekAgo))
        .toList();
  }

  // Tümünü okundu işaretle
  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
  }

  // Helper: Tipe göre renk getir
  Color getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.critical:
        return AppColors.neonRed;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.success:
        return AppColors.neonGreen;
      case NotificationType.info:
        return AppColors.neonBlue;
    }
  }

  // Helper: Tipe göre ikon getir
  IconData getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.critical:
        return Icons.error_outline;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }
}
