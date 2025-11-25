import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/glass_container.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final Map<String, String> _mockDatabase = {
    'admin': '1234',
    'mehmet': 'solar123',
    'demo': 'demo'
  };

  void _login() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    String user = _usernameController.text.trim();
    String pass = _passwordController.text.trim();

    if (_mockDatabase.containsKey(user) && _mockDatabase[user] == pass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hatalı kullanıcı adı veya şifre!'),
          backgroundColor: AppColors.neonRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. ARKA PLAN EFEKTLERİ (Sabit kalır)
          Positioned(
            top: -100, right: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonBlue.withOpacity(0.15),
                boxShadow: [BoxShadow(color: AppColors.neonBlue.withOpacity(0.2), blurRadius: 100, spreadRadius: 20)],
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
                boxShadow: [BoxShadow(color: AppColors.neonGreen.withOpacity(0.1), blurRadius: 100, spreadRadius: 20)],
              ),
            ),
          ),

          // 2. ORTALANMIŞ VE GENİŞLİĞİ SINIRLANMIŞ İÇERİK
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                // İŞTE SİHİRLİ DOKUNUŞ BURADA:
                // İçeriği maksimum 450px genişliğe sabitliyoruz.
                // Mobilde ekran 450'den küçükse otomatik küçülür,
                // PC'de 450'den büyükse 450'de kalır.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450), 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo ve Başlık
                      const Icon(Icons.bolt, size: 80, color: AppColors.neonGreen),
                      const SizedBox(height: 20),
                      const Text(
                        "SOLAR EMS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const Text(
                        "Energy Management System",
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      const SizedBox(height: 50),

                      // Cam Efektli Form Kartı
                      GlassContainer(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          children: [
                            const Text(
                              "Giriş Yap",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Kullanıcı Adı
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                hintText: 'Kullanıcı Adı',
                                hintStyle: const TextStyle(color: Colors.white38),
                                prefixIcon: const Icon(Icons.person_outline, color: AppColors.neonBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.neonBlue)),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Şifre
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                hintText: 'Şifre',
                                hintStyle: const TextStyle(color: Colors.white38),
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.neonBlue),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.neonBlue)),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Giriş Butonu
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonBlue,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  shadowColor: AppColors.neonBlue.withOpacity(0.5),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24, width: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                      )
                                    : const Text(
                                        "GİRİŞ YAP",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Şifremi Unuttum?", style: TextStyle(color: Colors.white54)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}