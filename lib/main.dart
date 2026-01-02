import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/tiktok_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TikTok RTMP Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoggedIn = false;
  bool _checkingLogin = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await TikTokService.checkLoginStatus();
    setState(() {
      _isLoggedIn = isLoggedIn;
      _checkingLogin = false;
    });
  }

  Future<void> _handleLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    if (result == true) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  Future<void> _importCookies() async {
    try {
      // Pick file JSON
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
        dialogTitle: 'Pilih file cookies.json',
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final pickedFile = result.files.single;
      
      // Read file content
      String jsonContent = '';
      
      if (pickedFile.path != null) {
        // Read from file path (Android/iOS)
        final file = File(pickedFile.path!);
        if (await file.exists()) {
          jsonContent = await file.readAsString();
        }
      } else if (pickedFile.bytes != null) {
        // Read from bytes (Web/other platforms)
        jsonContent = utf8.decode(pickedFile.bytes!);
      }

      if (jsonContent.isEmpty) {
        await _showManualImportDialog();
        return;
      }

      // Import cookies
      final importResult = await TikTokService.importCookiesFromJson(jsonContent);

      if (mounted) {
        if (importResult['success'] == true) {
          // Set logged in langsung, tidak perlu tunggu checkLoginStatus
          setState(() {
            _isLoggedIn = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(importResult['message'] ?? 'Cookies berhasil diimport'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${importResult['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Jika file picker gagal, tampilkan dialog manual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error membaca file: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      await _showManualImportDialog();
    }
  }

  Future<void> _showManualImportDialog() async {
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Cookies'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Paste isi file cookies.json di sini:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste JSON cookies di sini...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

     if (result == true && controller.text.isNotEmpty) {
       final importResult = await TikTokService.importCookiesFromJson(controller.text);

       if (mounted) {
         if (importResult['success'] == true) {
           // Set logged in langsung
           setState(() {
             _isLoggedIn = true;
           });
           
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(importResult['message'] ?? 'Cookies berhasil diimport'),
               backgroundColor: Colors.green,
               duration: const Duration(seconds: 2),
             ),
           );
         } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Error: ${importResult['error']}'),
               backgroundColor: Colors.red,
             ),
           );
         }
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLogin) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('TikTok RTMP Generator'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.video_library,
                  size: 80,
                  color: Colors.black,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Silakan login ke TikTok untuk mulai generate RTMP key',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _handleLogin,
                  icon: const Icon(Icons.login),
                  label: const Text('Login TikTok'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _importCookies,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Import Cookies dari File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'atau',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return HomeScreen(
      key: ValueKey(_isLoggedIn),
      onCookiesImported: () {
        // Refresh home screen jika cookies di-import
        setState(() {});
      },
    );
  }
}
