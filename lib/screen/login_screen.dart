import 'package:flutter/material.dart';
import '../service/user_service.dart';
import 'register_screen.dart';
import 'home_screen.dart'; // ✅ Import sudah aktif

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  void _doLogin() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email dan Password wajib diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await UserService().login(_emailCtrl.text, _passCtrl.text);

      setState(() => _isLoading = false);

      // Tampilkan pesan dari server
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Login Selesai")),
      );

      // CEK STATUS CODE 200 (BERHASIL)
      if (result['statusCode'] == 200) {
        print("✅ Login Berhasil! Pindah ke Home...");

        // Tunggu sebentar (1 detik) agar user sempat membaca SnackBar
        await Future.delayed(Duration(seconds: 1));

        if (mounted) {
          // ✅ PINDAH KE HALAMAN UTAMA
          // pushReplacement digunakan agar user tidak bisa back ke halaman login lagi
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 15),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 25),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _doLogin,
              child: Text("LOGIN", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text("Belum punya akun? Daftar di sini"),
            )
          ],
        ),
      ),
    );
  }
}