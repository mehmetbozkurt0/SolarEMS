import 'package:flutter/material.dart';
// core/constants.dart dosyası içe aktarılmalı
import '../core/constants.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String period; // Seçilen dönemi (Aylık/Yıllık) almak için

  const InvoiceDetailScreen({super.key, required this.period});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Düzeltildi: Yanlış renk değişkenleri düzeltildi
      appBar: AppBar(
        title: Text(
          'Fatura Geçmişi Detayları ($period)',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.neonBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          '$period Fatura Geçmişi Detay Ekranı',
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
