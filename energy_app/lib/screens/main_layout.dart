import 'package:energy_app/screens/ai_screen.dart';
import 'package:energy_app/screens/analysis_screen.dart';
import 'package:energy_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'package:energy_app/screens/dashboard_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  // Diğer sayfalar yapıldıkça buraya eklenecek
  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalysisScreen(),
    const AIOptimizationScreen(),
    const SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // WEB: Sidebar Menü
          if (isDesktop)
            _GlassSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
            ),

          // ANA İÇERİK (Arkaplan Süslemeli)
          Expanded(
            child: Stack(
              children: [
                // Arkaplan Gradient Süslemeleri
                Positioned(
                  top: -100, right: -100,
                  child: Container(
                    width: 400, height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonBlue.withOpacity(0.15),
                      boxShadow: [BoxShadow(color: AppColors.neonBlue.withOpacity(0.2), blurRadius: 100)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50, left: -50,
                  child: Container(
                    width: 300, height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonGreen.withOpacity(0.1),
                      boxShadow: [BoxShadow(color: AppColors.neonGreen.withOpacity(0.1), blurRadius: 100)],
                    ),
                  ),
                ),

                // Sayfa İçeriği
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
      // MOBİL: Bottom Navigation Bar
      bottomNavigationBar: isDesktop
          ? null
          : _GlassBottomBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

// Sidebar ve BottomBar bu dosyaya özel (private) kalabilir
class _GlassSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _GlassSidebar({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppColors.cardGradientEnd,
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.bolt, color: AppColors.neonGreen, size: 50),
          const SizedBox(height: 10),
          const Text("SOLAR EMS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 50),
          _buildMenuItem(0, Icons.dashboard_rounded, "Genel Bakış"),
          _buildMenuItem(1, Icons.analytics_rounded, "Analiz & Rapor"),
          _buildMenuItem(2, Icons.auto_awesome, "AI Asistan"),
          _buildMenuItem(3, Icons.settings, "Ayarlar"),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, IconData icon, String label) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonBlue.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.neonBlue : Colors.white38),
            const SizedBox(width: 15),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _GlassBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const _GlassBottomBar({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF181A26),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.dashboard_rounded, "Özet"),
          _buildNavItem(1, Icons.analytics_rounded, "Analiz"),
          _buildNavItem(2, Icons.auto_awesome, "AI"),
          _buildNavItem(3, Icons.settings, "Ayarlar"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? AppColors.neonBlue : Colors.white38),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.neonBlue : Colors.white38)),
        ],
      ),
    );
  }
}