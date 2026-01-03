import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // User agent desktop agar TikTok tidak redirect ke app native
    const desktopUserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(desktopUserAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            
            // Check jika sudah login dan redirect ke halaman yang tepat
            if (url.contains('tiktok.com/foryou') || 
                url.contains('tiktok.com/@') ||
                url.contains('studio.tiktok.com')) {
              _extractCookies();
            }
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            // Check jika sudah login (redirect ke studio atau home)
            if ((url.contains('studio.tiktok.com') || 
                 url.contains('tiktok.com/foryou') ||
                 url.contains('tiktok.com/@')) && 
                !url.contains('login') && 
                !url.contains('signup')) {
              _extractCookies();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            // Hanya izinkan HTTP/HTTPS, blokir scheme lain (intent://, tiktok://, dll)
            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }
            // Blokir URL dengan scheme yang tidak dikenal
            return NavigationDecision.prevent;
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${error.description}')),
              );
            }
          },
        ),
      )
      // Gunakan URL login yang sesuai dengan dokumentasi TikTok untuk Live Studio
      // URL ini sama dengan yang digunakan di source code Python
      ..loadRequest(Uri.parse('https://www.tiktok.com/login?is_modal=1&hide_toggle_login_signup=1&enter_method=live_studio&enter_from=live_studio&lang=en'));
  }
  
  Future<void> _extractCookies() async {
    try {
      // Tunggu sebentar untuk memastikan cookies sudah ter-set
      await Future.delayed(const Duration(milliseconds: 2000));
      
      final currentUrl = await _controller.currentUrl();
      print('Current URL: $currentUrl');
      
      String cookieString = '';
      
      // Coba ambil cookies menggunakan platform channel (Android CookieManager)
      // Ini bisa mendapatkan HttpOnly cookies
      try {
        const platform = MethodChannel('com.fskhri.tiktokgeneratertmp/cookies');
        final cookies = await platform.invokeMethod<String>('getCookies', {'url': 'https://www.tiktok.com'});
        if (cookies != null && cookies.isNotEmpty) {
          cookieString = cookies;
          print('Cookies dari CookieManager (Android): ${cookieString.length} chars');
        }
      } catch (e) {
        print('Error menggunakan platform channel: $e');
      }
      
      // Fallback: gunakan JavaScript jika platform channel gagal
      if (cookieString.isEmpty) {
        final cookieResult = await _controller.runJavaScriptReturningResult(
          'document.cookie'
        );
        cookieString = cookieResult.toString().replaceAll('"', '');
        print('Cookies dari JavaScript: ${cookieString.length} chars');
      }
      
      // Jika cookies kosong, coba beberapa kali
      int retryCount = 0;
      while ((cookieString.isEmpty || cookieString == 'null') && retryCount < 3) {
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Coba platform channel lagi
        try {
          const platform = MethodChannel('com.fskhri.tiktokgeneratertmp/cookies');
          final cookies = await platform.invokeMethod<String>('getCookies', {'url': 'https://www.tiktok.com'});
          if (cookies != null && cookies.isNotEmpty) {
            cookieString = cookies;
            break;
          }
        } catch (e) {
          // Fallback ke JavaScript
          final retryResult = await _controller.runJavaScriptReturningResult(
            'document.cookie'
          );
          cookieString = retryResult.toString().replaceAll('"', '');
        }
        retryCount++;
      }
      
      print('Final cookie string length: ${cookieString.length}');
      if (cookieString.length > 200) {
        print('Cookie preview: ${cookieString.substring(0, 200)}...');
      } else {
        print('Cookies: $cookieString');
      }
      
      // Check apakah ada cookie penting seperti sessionid atau sid_tt
      final hasSessionId = cookieString.contains('sessionid') || cookieString.contains('sid_tt');
      final hasSidGuard = cookieString.contains('sid_guard');
      print('Has sessionid/sid_tt: $hasSessionId');
      print('Has sid_guard: $hasSidGuard');
      
      if (cookieString.isNotEmpty && cookieString != 'null') {
        // Simpan cookies
        await TikTokService.saveCookies(cookieString);
        
        if (mounted) {
          // Tampilkan pesan sesuai status cookies
          final isComplete = hasSessionId && hasSidGuard;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isComplete
                ? 'Login berhasil! Cookies lengkap tersimpan.'
                : hasSessionId
                  ? 'Login berhasil! Cookies tersimpan (beberapa cookie mungkin kurang).'
                  : 'Cookies tersimpan, tapi tidak lengkap. Import dari file untuk hasil terbaik.'),
              backgroundColor: isComplete ? Colors.green : hasSessionId ? Colors.orange : Colors.red,
              duration: const Duration(seconds: 4),
              action: !isComplete
                ? SnackBarAction(
                    label: 'Import File',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.of(context).pop(false); // Kembali ke main screen untuk import
                    },
                  )
                : null,
            ),
          );
          
          // Jika cookies lengkap, langsung kembali
          if (isComplete) {
            await Future.delayed(const Duration(milliseconds: 500));
            Navigator.of(context).pop(true);
          } else {
            // Tunggu user memilih action
            await Future.delayed(const Duration(seconds: 4));
            if (mounted && hasSessionId) {
              // Jika ada sessionid, tetap simpan dan kembali
              Navigator.of(context).pop(true);
            }
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat mengambil cookies. Coba import dari file cookies.json.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Extract cookies error: $e');
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

