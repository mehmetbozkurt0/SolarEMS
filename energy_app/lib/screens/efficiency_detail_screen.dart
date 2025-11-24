import 'package:flutter/material.dart';
// core/constants.dart dosyası içe aktarılmalı
import '../core/constants.dart';

class EfficiencyDetailScreen extends StatelessWidget {
  final String period; // Seçilen dönemi (Aylık/Yıllık) almak için

  const EfficiencyDetailScreen({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Düzeltildi: Yanlış renk değişkenleri düzeltildi
      appBar: AppBar(
        title: Text(
          'Verimlilik Analizi Detayları ($period)',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.neonBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          '$period Verimlilik Analizi Detay Ekranı',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
