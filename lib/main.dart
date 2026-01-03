import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/tiktok_service.dart';
import 'l10n/app_localizations.dart';

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('id', ''), // Indonesian
      ],
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
    // Cek apakah cookies sudah ada
    final cookies = await TikTokService.getCookies();
    if (cookies != null && cookies.isNotEmpty) {
      // Cookies sudah ada, langsung set logged in
      // Tidak perlu check login status karena bisa lambat
      setState(() {
        _isLoggedIn = true;
        _checkingLogin = false;
      });
    } else {
      // Tidak ada cookies, perlu login/import
      setState(() {
        _isLoggedIn = false;
        _checkingLogin = false;
      });
    }
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
          // Set logged in langsung, cookies sudah tersimpan permanen
          setState(() {
            _isLoggedIn = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(importResult['message'] ?? 'Cookies berhasil diimport dan tersimpan'),
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorReadingFile + ': $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      await _showManualImportDialog();
    }
  }

  Future<void> _showManualImportDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importCookiesTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pasteCookies,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 10,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: l10n.pasteJsonCookies,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.import),
          ),
        ],
      ),
    );

     if (result == true && controller.text.isNotEmpty) {
       final importResult = await TikTokService.importCookiesFromJson(controller.text);

       if (mounted) {
         final l10n = AppLocalizations.of(context)!;
         if (importResult['success'] == true) {
           // Cookies sudah tersimpan permanen, tidak perlu import lagi
           setState(() {
             _isLoggedIn = true;
           });
           
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(importResult['message'] ?? l10n.cookiesImported),
               backgroundColor: Colors.green,
               duration: const Duration(seconds: 2),
             ),
           );
         } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('${l10n.error}: ${importResult['error']}'),
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
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
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
                Text(
                  l10n.welcome,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.welcomeMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _handleLogin,
                  icon: const Icon(Icons.login),
                  label: Text(l10n.loginTikTok),
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
                  label: Text(l10n.importCookies),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    l10n.cookiesNote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
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
