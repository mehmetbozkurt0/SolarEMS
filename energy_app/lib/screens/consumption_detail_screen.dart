import 'package:flutter/material.dart';
// core/constants.dart dosyası içe aktarılmalı
import '../core/constants.dart';

class ConsumptionDetailScreen extends StatelessWidget {
  final String period; // Seçilen dönemi (Aylık/Yıllık) almak için

  const ConsumptionDetailScreen({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Düzeltildi: Yanlış renk değişkenleri düzeltildi
      appBar: AppBar(
        title: Text(
          'Ev Tüketimi Detayları ($period)',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.neonBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          '$period Ev Tüketimi Detay Ekranı',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
