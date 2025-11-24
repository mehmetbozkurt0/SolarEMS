import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';
import '../core/api_service.dart'; // ApiService eklendi

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  List<dynamic> _devices = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final devices = await _apiService.getDevices();
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      print("Cihaz yükleme hatası: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Bağlantı hatası!")));
    }
  }

  Future<void> _addDevice(String name, String type) async {
    final newDevice = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(), // Geçici ID
      'name': name,
      'type': type,
      'status': 'Offline',
      'power': '0 kW',
    };

    try {
      await _apiService.addDevice(newDevice);
      _loadData(); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cihaz eklenemedi.")));
    }
  }

  Future<void> _removeDevice(int index) async {
    final deviceId = _devices[index]['id'];
    try {
      await _apiService.deleteDevice(deviceId);
      _loadData(); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Cihaz silinemedi.")));
    }
  }

  // Toggle için API'de henüz endpoint yok, mock olarak UI'da bırakıyorum veya PUT yazılabilir.
  void _toggleDeviceStatus(int index) {
    // Backend'de status update endpoint'i eklendiğinde burası güncellenecek.
    setState(() {
      if (_devices[index]['status'] == 'Online') {
        _devices[index]['status'] = 'Offline';
      } else if (_devices[index]['status'] == 'Offline') {
        _devices[index]['status'] = 'Online';
      }
    });
  }

  int _getIconCodeForType(String type) {
    switch (type) {
      case 'Inverter':
        return Icons.solar_power.codePoint;
      case 'Batarya':
        return Icons.battery_std.codePoint;
      case 'Sayaç':
        return Icons.speed.codePoint;
      default:
        return Icons.devices_other.codePoint;
    }
  }

  void _showAddDeviceDialog() {
    final TextEditingController nameController = TextEditingController();
    String selectedType = 'Tüketici';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardSurface,
          title: const Text(
            "Yeni Cihaz Ekle",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Cihaz Adı",
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedType,
                dropdownColor: AppColors.cardSurface,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Cihaz Tipi",
                  labelStyle: TextStyle(color: Colors.white54),
                ),
                items:
                    ['Inverter', 'Batarya', 'Sayaç', 'Tüketici']
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                onChanged: (val) => selectedType = val!,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "İptal",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonBlue,
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _addDevice(nameController.text, selectedType);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Ekle",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cihaz Yönetimi",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDeviceDialog,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    _devices.isEmpty
                        ? const Center(
                          child: Text(
                            "Henüz kayıtlı cihaz yok.",
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            // Icon code backend'den gelmiyor, client tarafında type'a göre belirleyelim
                            final iconCode = _getIconCodeForType(
                              device['type'],
                            );
                            final iconData = IconData(
                              iconCode,
                              fontFamily: 'MaterialIcons',
                            );
                            final bool isOnline =
                                device['status'] == 'Online' ||
                                device['status'] == 'Charging';

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: GlassContainer(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        iconData,
                                        color: AppColors.neonBlue,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _toggleDeviceStatus(index),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              device['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isOnline
                                                            ? AppColors
                                                                .neonGreen
                                                            : AppColors.neonRed,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "${device['type']} • ${device['status']}",
                                                  style: TextStyle(
                                                    color:
                                                        isOnline
                                                            ? AppColors
                                                                .neonGreen
                                                            : Colors.white38,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      device['power'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.neonRed,
                                      ),
                                      onPressed: () => _removeDevice(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
    );
  }
}
