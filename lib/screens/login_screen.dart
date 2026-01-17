import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idUserController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> _handleLogin() async {
    String idUser = _idUserController.text.trim();
    String password = _passwordController.text.trim();

    if (idUser.isEmpty || password.isEmpty) {
      _showError("ID User dan Password tidak boleh kosong");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('id_user', isEqualTo: idUser)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        var userData = userQuery.docs.first.data();
        String role = userData['role'] ?? 'mahasiswa';
        String namaLengkap = userData['nama'] ?? 'User';

        if (password == idUser) {
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, AppRoutes.adminHome);
          } else {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.userHome,
              arguments: {
                'id_user': idUser,
                'nama': namaLengkap,
              },
            );
          }
        } else {
          _showError("Password salah!");
        }
      } else {
        _showError("User tidak ditemukan");
      }
    } catch (e) {
      _showError("Kesalahan: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _idUserController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan tinggi layar untuk responsivitas
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      body: Stack(
        children: [
          // Background Gradient (Bagian Atas)
          Container(
            height: screenHeight * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
          ),
          
          // Konten Utama
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Icon Logo
                    const Icon(Icons.menu_book_rounded, size: 80, color: Colors.white),
                    const SizedBox(height: 16),
                    const Text(
                      "PI-BOOK LP3I",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Text(
                      "Sistem Informasi Perpustakaan Digital",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // Card Form Login
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Login Pengguna",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Input ID User
                          const Text("NIM / ID User", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _idUserController,
                            decoration: InputDecoration(
                              hintText: "Masukkan NIM anda",
                              prefixIcon: const Icon(Icons.person_outline, size: 22),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Input Password
                          const Text("Password", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              hintText: "Masukkan Password",
                              prefixIcon: const Icon(Icons.lock_outline, size: 22),
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () => setState(() => _isObscure = !_isObscure),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          
                          // Tombol Login
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "MASUK SEKARANG",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "© 2024 Politeknik LP3I\nDigital Library System v1.0",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}