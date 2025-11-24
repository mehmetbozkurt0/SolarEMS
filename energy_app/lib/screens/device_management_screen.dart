import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  // Mock Cihaz Listesi
  final List<Map<String, dynamic>> _devices = [
    {
      'id': '1',
      'name': 'Ana İnverter',
      'type': 'Inverter',
      'status': 'Online',
      'power': '4.2 kW',
      'icon': Icons.solar_power,
    },
    {
      'id': '2',
      'name': 'Tesla Powerwall',
      'type': 'Batarya',
      'status': 'Charging',
      'power': '+2.1 kW',
      'icon': Icons.battery_charging_full,
    },
    {
      'id': '3',
      'name': 'Akıllı Sayaç',
      'type': 'Sayaç',
      'status': 'Online',
      'power': '--',
      'icon': Icons.speed,
    },
    {
      'id': '4',
      'name': 'Salon Kliması',
      'type': 'Tüketici',
      'status': 'Offline',
      'power': '0 kW',
      'icon': Icons.ac_unit,
    },
  ];

  // Cihaz Ekleme Diyaloğu
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
                    ['Inverter', 'Batarya', 'Sayaç', 'Tüketici'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
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
                  setState(() {
                    _devices.add({
                      'id': DateTime.now().toString(),
                      'name': nameController.text,
                      'type': selectedType,
                      'status':
                          'Offline', // Yeni eklenen cihaz varsayılan offline
                      'power': '0 kW',
                      'icon': _getIconForType(selectedType),
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cihaz başarıyla eklendi."),
                      backgroundColor: AppColors.neonGreen,
                    ),
                  );
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

  // Cihaz Silme
  void _removeDevice(int index) {
    final removedDevice = _devices[index];
    setState(() {
      _devices.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${removedDevice['name']} silindi."),
        action: SnackBarAction(
          label: "Geri Al",
          textColor: AppColors.neonBlue,
          onPressed: () {
            setState(() {
              _devices.insert(index, removedDevice);
            });
          },
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Inverter':
        return Icons.solar_power;
      case 'Batarya':
        return Icons.battery_std;
      case 'Sayaç':
        return Icons.speed;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cihaz Yönetimi (İŞL.13)",
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
      body: Padding(
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
                    return Dismissible(
                      key: Key(device['id']),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _removeDevice(index),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.neonRed,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                  device['icon'],
                                  color: AppColors.neonBlue,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Text(
                                      "${device['type']} • ${device['status']}",
                                      style: TextStyle(
                                        color:
                                            device['status'] == 'Online' ||
                                                    device['status'] ==
                                                        'Charging'
                                                ? AppColors.neonGreen
                                                : Colors.white38,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                device['power'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeviceDialog,
        backgroundColor: AppColors.neonBlue,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
