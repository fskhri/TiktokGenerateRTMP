import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/tiktok_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }
  
  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            // Check jika sudah login (redirect ke studio atau home)
            if ((url.contains('studio.tiktok.com') || 
                 url.contains('tiktok.com/@')) && 
                !url.contains('login') && 
                !url.contains('signup')) {
              _extractCookies();
            }
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${error.description}')),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.tiktok.com/login/phone-or-email/email'));
  }
  
  Future<void> _extractCookies() async {
    try {
      // Get cookies dari WebView menggunakan JavaScript
      final cookieResult = await _controller.runJavaScriptReturningResult(
        'document.cookie'
      );
      
      String cookieString = cookieResult.toString().replaceAll('"', '');
      
      // Jika cookies kosong, coba ambil dari semua domain
      if (cookieString.isEmpty || cookieString == 'null') {
        // Tunggu sebentar untuk memastikan cookies sudah ter-set
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Coba lagi
        final retryResult = await _controller.runJavaScriptReturningResult(
          'document.cookie'
        );
        cookieString = retryResult.toString().replaceAll('"', '');
      }
      
      if (cookieString.isNotEmpty) {
        // Simpan cookies
        await TikTokService.saveCookies(cookieString);
        
        // Tunggu sebentar sebelum check login
        await Future.delayed(const Duration(seconds: 1));
        
        // Check login status
        final isLoggedIn = await TikTokService.checkLoginStatus();
        
        if (mounted) {
          if (isLoggedIn) {
            Navigator.of(context).pop(true);
          } else {
            // Jika check login gagal, tetap simpan cookies dan biarkan user lanjut
            Navigator.of(context).pop(true);
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat mengambil cookies. Pastikan Anda sudah login.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login TikTok'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

