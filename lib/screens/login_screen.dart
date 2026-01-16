import 'package:flutter/material.dart';
// Import AppRoutes untuk memanggil konstanta nama rute
import '../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // LOGIKA AUTH BERDASARKAN RUTE (AppRoutes)
    if (email == "admin.test" && password == "password") {
      // Navigasi ke Dashboard Admin menggunakan Named Route
      Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
    } else if (email.isNotEmpty && password.isNotEmpty) {
      // Navigasi ke Dashboard Mahasiswa menggunakan Named Route
      Navigator.pushReplacementNamed(context, AppRoutes.userHome);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email dan Password harus diisi"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Ungu
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF6366F1),
                child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                "PiBook LP3I",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Masuk untuk mengakses sistem perpustakaan",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Form Email
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "Masukkan email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form Password
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Password", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Masuk
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),

              // Kotak Info Demo Login
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Demo Login:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                    const SizedBox(height: 8),
                    Text(
                      "Admin: admin.test / password",
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                    ),
                    Text(
                      "Mahasiswa: email apapun / password apapun",
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}