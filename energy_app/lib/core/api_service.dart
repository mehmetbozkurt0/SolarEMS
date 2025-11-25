import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator için 10.0.2.2, iOS Simulator için 127.0.0.1
  // Gerçek cihaz için bilgisayarının yerel IP'si (örn: 192.168.1.35)
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // 1. AI Recommendation Getir
  Future<Map<String, dynamic>> getAiRecommendation() async {
    final response = await http.get(Uri.parse('$baseUrl/ai/recommendation'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('AI önerisi alınamadı');
    }
  }

  // YENİ EKLENDİ: 1.1 AI Önerisini Uygula
  Future<bool> applyRecommendation() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/ai/recommendation/apply'));
      return response.statusCode == 200;
    } catch (e) {
      print("AI Apply Error: $e");
      return false;
    }
  }

  // 2. Grafik Verisi Getir
  Future<List<dynamic>> getDailyProductionChart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analysis/chart/production/daily'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Grafik verisi alınamadı');
    }
  }

  // 3. Cihazları Listele
  Future<List<dynamic>> getDevices() async {
    final response = await http.get(Uri.parse('$baseUrl/devices'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Cihazlar yüklenemedi');
    }
  }

  // 4. Cihaz Ekle
  Future<void> addDevice(Map<String, dynamic> deviceData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/devices'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(deviceData),
    );
    if (response.statusCode != 200) {
      throw Exception('Cihaz eklenemedi');
    }
  }

  // 5. Cihaz Sil
  Future<void> deleteDevice(String deviceId) async {
    final response = await http.delete(Uri.parse('$baseUrl/devices/$deviceId'));
    if (response.statusCode != 200) {
      throw Exception('Cihaz silinemedi');
    }
  }

  // 6. Batarya Durumlarını Getir
  Future<List<dynamic>> getBatteries() async {
    final response = await http.get(Uri.parse('$baseUrl/battery'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Batarya verisi alınamadı');
    }
  }

  // 7. Batarya Ayarlarını Güncelle
  Future<void> updateBatterySettings(
    String batteryId,
    Map<String, dynamic> settings,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/battery/$batteryId/settings'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(settings),
    );
    if (response.statusCode != 200) {
      throw Exception('Batarya ayarı güncellenemedi');
    }
  }

  // 8. Detaylı Tahmin Verisi Getir
  Future<List<dynamic>> getDetailedForecast() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analysis/forecast/detailed'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Detaylı tahmin verisi alınamadı');
    }
  }

  // 9. Finansal Özet Verisi Getir (Tarife Ekranı)
  Future<Map<String, dynamic>> getFinancialSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analysis/financial/summary'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Finansal özet verisi alınamadı');
    }
  }

  // 10. Çevresel Etki Verisi Getir (Analiz Ekranı)
  Future<Map<String, dynamic>> getEnvironmentalImpact() async {
    final response = await http.get(
      Uri.parse('$baseUrl/analysis/environmental/impact'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Çevresel etki verisi alınamadı');
    }
  }
}