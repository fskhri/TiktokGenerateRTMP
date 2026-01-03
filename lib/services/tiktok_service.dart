import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TikTokService {
  static String? _baseUrl;
  static const String liveStudioUrl = 'https://studio.tiktok.com';
  
  // Get server URL dynamically
  static Future<String> getServerUrl() async {
    if (_baseUrl != null) {
      return _baseUrl!;
    }
    
    try {
      final url = 'https://tnc16-platform-useast1a.tiktokv.com/get_domains/v4/?aid=8311&ttwebview_version=1130022001&device_platform=win';
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      
      for (var action in data['data']['ttnet_dispatch_actions']) {
        if (action['param'] != null && 
            action['param']['strategy_info'] != null &&
            action['param']['strategy_info'].toString().contains('webcast-normal.tiktokv.com')) {
          var serverUrl = action['param']['strategy_info']['webcast-normal.tiktokv.com'];
          
          for (var action2 in data['data']['ttnet_dispatch_actions']) {
            if (action2['param'] != null && 
                action2['param']['strategy_info'] != null &&
                action2['param']['strategy_info'][serverUrl] != null) {
              serverUrl = action2['param']['strategy_info'][serverUrl];
              _baseUrl = 'https://$serverUrl/';
              return _baseUrl!;
            }
          }
          _baseUrl = 'https://$serverUrl/';
          return _baseUrl!;
        }
      }
    } catch (e) {
      print('Error getting server URL: $e');
    }
    
    // Fallback to default
    _baseUrl = 'https://webcast16-normal-c-useast2a.tiktokv.com/';
    return _baseUrl!;
  }
  
  // Simpan cookies
  static Future<void> saveCookies(String cookies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tiktok_cookies', cookies);
  }
  
  // Ambil cookies
  static Future<String?> getCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tiktok_cookies');
  }
  
  // Parse cookies dari string
  static Map<String, String> parseCookies(String cookieString) {
    final Map<String, String> cookies = {};
    final List<String> cookieList = cookieString.split(';');
    
    for (String cookie in cookieList) {
      final parts = cookie.trim().split('=');
      if (parts.length == 2) {
        cookies[parts[0].trim()] = parts[1].trim();
      }
    }
    
    return cookies;
  }
  
  
  // Get Live Studio version
  static Future<String> getLiveStudioVersion() async {
    try {
      final url = 'https://tron-sg.bytelemon.com/api/sdk/check_update';
      final params = {
        'pid': '7393277106664249610',
        'uid': '7464643088460875280',
        'branch': 'studio/release/stable',
        'buildId': '0',
      };
      final response = await http.get(Uri.parse(url).replace(queryParameters: params));
      final data = jsonDecode(response.body);
      return data['data']['manifest']['win32']['version'] ?? '0.99.0';
    } catch (e) {
      print('Error getting version: $e');
      return '0.99.0';
    }
  }

  // Upload thumbnail (sama seperti source code Python)
  static Future<String?> uploadThumbnail(String filePath, String baseUrl, Map<String, String> params) async {
    try {
      final cookies = await getCookies();
      if (cookies == null || cookies.isEmpty) {
        return null;
      }
      
      final version = await getLiveStudioVersion();
      final headers = <String, String>{
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) TikTokLIVEStudio/$version Chrome/108.0.5359.215 Electron/22.3.18-tt.8.release.main.44 TTElectron/22.3.18-tt.8.release.main.44 Safari/537.36',
        'Cookie': cookies,
      };
      
      final file = await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: 'crop_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}webcast/room/upload/image/').replace(queryParameters: params),
      );
      
      request.headers.addAll(headers);
      request.files.add(file);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']?['uri']?.toString();
      }
      
      return null;
    } catch (e) {
      print('Error uploading thumbnail: $e');
      return null;
    }
  }
  
  // Generate stream key
  static Future<Map<String, dynamic>> generateStreamKey({
    required String title,
    String? hashtagId,
    String? gameTagId,
    bool enableReplay = false,
    bool closeRoomWhenStreamEnds = false,
    String regionPriority = '',
    bool isMatureContent = false,
    String? thumbnailPath,
  }) async {
    try {
      final cookies = await getCookies();
      
      print('=== TikTokService: Generate Stream Key ===');
      print('Title: $title');
      print('Hashtag ID: $hashtagId');
      print('Game Tag ID: $gameTagId');
      print('Region: $regionPriority');
      print('Cookies loaded: ${cookies != null && cookies.isNotEmpty}');
      
      if (cookies == null || cookies.isEmpty) {
        throw Exception('Silakan login terlebih dahulu');
      }
      
      // Log cookies untuk debugging (jangan log full untuk privacy)
      print('Cookies length: ${cookies.length}');
      print('Cookies preview: ${cookies.substring(0, cookies.length > 150 ? 150 : cookies.length)}...');
      
      // Check apakah ada cookie penting
      final hasSessionId = cookies.contains('sessionid') || cookies.contains('sid_tt');
      final hasSidGuard = cookies.contains('sid_guard');
      print('Has sessionid/sid_tt: $hasSessionId');
      print('Has sid_guard: $hasSidGuard');
      
      if (!hasSessionId) {
        print('WARNING: Cookies mungkin tidak lengkap. Pastikan login via WebView atau import dari file.');
      }
      
      // Get server URL
      final baseUrl = await getServerUrl();
      print('Base URL: $baseUrl');
      
      // Get Live Studio version
      final version = await getLiveStudioVersion();
      print('Live Studio version: $version');
      
      // Build headers sesuai source code Python
      final headers = <String, String>{
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) TikTokLIVEStudio/$version Chrome/108.0.5359.215 Electron/22.3.18-tt.8.release.main.44 TTElectron/22.3.18-tt.8.release.main.44 Safari/537.36',
        'Cookie': cookies,
      };
      
      // Build query params sesuai source code Python
      final webcastSdkVersion = version.replaceAll('.', '').replaceAll('0', '');
      final params = <String, String>{
        'aid': '8311',
        'app_name': 'tiktok_live_studio',
        'channel': 'studio',
        'device_platform': 'windows',
        'priority_region': regionPriority,
        'live_mode': '6',
        'version_code': version,
        'webcast_sdk_version': webcastSdkVersion,
        'webcast_language': 'en',
        'app_language': 'en',
        'language': 'en',
        'browser_version': '5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) TikTokLIVEStudio/0.69.2 Chrome/108.0.5359.215 Electron/22.3.18-tt.8.release.main.44 TTElectron/22.3.18-tt.8.release.main.44 Safari/537.36',
        'browser_name': 'Mozilla',
        'browser_platform': 'Win32',
        'browser_language': 'en-US',
        'screen_height': '1080',
        'screen_width': '1920',
        'timezone_name': 'Asia/Jakarta',
        'device_id': '7378193331631310352',
        'install_id': '7378196538524927745',
      };
      
      // Upload thumbnail jika ada
      String? coverUri = '';
      if (thumbnailPath != null && thumbnailPath.isNotEmpty) {
        print('Uploading thumbnail: $thumbnailPath');
        coverUri = await uploadThumbnail(thumbnailPath, baseUrl, params);
        print('Thumbnail URI: $coverUri');
      }
      
      // Build form data sesuai source code Python
      final data = <String, String>{
        'title': title,
        'live_studio': '1',
        'gen_replay': enableReplay.toString().toLowerCase(),
        'chat_auth': '1',
        'cover_uri': coverUri ?? '',
        'close_room_when_close_stream': closeRoomWhenStreamEnds.toString().toLowerCase(),
        'hashtag_id': hashtagId ?? '',
        'game_tag_id': gameTagId ?? '0',
        'screenshot_cover_status': '1',
        'live_sub_only': '0',
        'chat_sub_only_auth': '2',
        'multi_stream_scene': '0',
        'gift_auth': '1',
        'chat_l2': '1',
        'star_comment_switch': 'true',
        'multi_stream_source': '1',
      };
      
      if (isMatureContent) {
        data['age_restricted'] = '4';
      }
      
      print('Request params: $params');
      print('Request data: $data');
      
      // Request untuk create room - menggunakan form data, bukan JSON
      final createRoomUrl = '${baseUrl}webcast/room/create/';
      print('Creating room at: $createRoomUrl');
      
      final uri = Uri.parse(createRoomUrl).replace(queryParameters: params);
      final createResponse = await http.post(
        uri,
        headers: headers,
        body: data,
      );
      
      final createResponseBody = createResponse.body;
      print('Create room response status: ${createResponse.statusCode}');
      print('Create room response body: $createResponseBody');
      
      if (createResponse.statusCode != 200) {
        throw Exception('Gagal membuat room: ${createResponse.statusCode}\nResponse: $createResponseBody');
      }
      
      final createData = jsonDecode(createResponseBody);
      print('Create room data: $createData');
      
      // Check for error in response
      if (createData['data'] != null && createData['data']['prompts'] != null) {
        final prompts = createData['data']['prompts'];
        if (prompts.toString().toLowerCase().contains('login') || 
            prompts.toString().toLowerCase().contains('please login')) {
          throw Exception('Please login first. Cookies mungkin tidak valid atau expired. Coba login ulang atau import cookies dari file.');
        }
        throw Exception('Error: $prompts');
      }
      
      if (createData['status_code'] != null && createData['status_code'] != 0) {
        final errorMsg = createData['status_msg'] ?? 'Unknown error';
        final errorData = createData['data'] ?? {};
        
        // Check jika error terkait login
        if (errorMsg.toLowerCase().contains('login') || 
            errorMsg.toString().toLowerCase().contains('please login') ||
            errorData.toString().toLowerCase().contains('login')) {
          throw Exception('Please login first. Cookies mungkin tidak valid atau expired. Coba login ulang atau import cookies dari file.');
        }
        
        throw Exception('Error create room: $errorMsg\nData: $errorData');
      }
      
      // Extract stream info dari response
      // Response sudah memberikan full RTMP URL lengkap di rtmp_push_url
      final fullRtmpUrl = createData['data']['stream_url']['rtmp_push_url'];
      final shareUrl = createData['data']['share_url'];
      
      print('Full RTMP URL: $fullRtmpUrl');
      
      // Extract base URL dan stream key untuk backward compatibility
      // Base URL adalah bagian sebelum stream key (termasuk trailing slash)
      // Stream key adalah bagian setelah slash terakhir
      final splitIndex = fullRtmpUrl.lastIndexOf('/');
      final baseStreamUrl = fullRtmpUrl.substring(0, splitIndex + 1);
      final streamKey = fullRtmpUrl.substring(splitIndex + 1);
      
      print('Base URL: $baseStreamUrl');
      print('Stream Key: $streamKey');
      
      return {
        'success': true,
        'fullRtmpUrl': fullRtmpUrl, // Full RTMP URL lengkap (gabungan base + stream key)
        'baseUrl': baseStreamUrl,
        'streamKey': streamKey,
        'shareUrl': shareUrl,
        'roomId': createData['data']['room_id'] ?? '',
      };
    } catch (e) {
      // Log error untuk debugging
      print('TikTokService Error: $e');
      print('Stack trace: ${StackTrace.current}');
      
      String errorMessage = 'Unknown error';
      if (e is Exception) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else if (e is FormatException) {
        errorMessage = 'Format error: ${e.message}';
      } else {
        errorMessage = e.toString();
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'fullError': e.toString(),
      };
    }
  }
  
  // End stream
  static Future<bool> endStream(String roomId) async {
    try {
      final cookies = await getCookies();
      if (cookies == null || cookies.isEmpty) {
        return false;
      }
      
      final baseUrl = await getServerUrl();
      final version = await getLiveStudioVersion();
      
      final headers = <String, String>{
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) TikTokLIVEStudio/$version Chrome/108.0.5359.215 Electron/22.3.18-tt.8.release.main.44 TTElectron/22.3.18-tt.8.release.main.44 Safari/537.36',
        'Cookie': cookies,
      };
      
      final params = <String, String>{
        'aid': '8311',
        'app_name': 'tiktok_live_studio',
        'channel': 'studio',
        'device_platform': 'windows',
        'live_mode': '6',
      };
      
      final uri = Uri.parse('${baseUrl}webcast/room/finish_abnormal/').replace(queryParameters: params);
      final response = await http.post(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['prompts'] != null) {
          return false;
        }
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check login status
  static Future<bool> checkLoginStatus() async {
    try {
      final cookies = await getCookies();
      if (cookies == null || cookies.isEmpty) {
        return false;
      }
      
      final headers = <String, String>{
        'Cookie': cookies,
      };
      
      final response = await http.get(
        Uri.parse('$liveStudioUrl/api/live/studio/check_login/'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status_code'] == 0;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Import cookies dari file JSON
  static Future<Map<String, dynamic>> importCookiesFromJson(String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString);
      final List<String> cookiePairs = [];
      
      // Handle format array of cookie objects
      if (jsonData is List) {
        for (var cookie in jsonData) {
          if (cookie is Map) {
            final name = cookie['name']?.toString() ?? '';
            final value = cookie['value']?.toString() ?? '';
            if (name.isNotEmpty && value.isNotEmpty) {
              cookiePairs.add('$name=$value');
            }
          }
        }
      } 
      // Handle format object dengan cookies
      else if (jsonData is Map) {
        // Format 1: { "cookies": [...] }
        if (jsonData.containsKey('cookies') && jsonData['cookies'] is List) {
          for (var cookie in jsonData['cookies']) {
            if (cookie is Map) {
              final name = cookie['name']?.toString() ?? '';
              final value = cookie['value']?.toString() ?? '';
              if (name.isNotEmpty && value.isNotEmpty) {
                cookiePairs.add('$name=$value');
              }
            }
          }
        }
        // Format 2: { "sessionid": "...", "sid_tt": "..." }
        else {
          jsonData.forEach((key, value) {
            if (value is String && value.isNotEmpty) {
              cookiePairs.add('$key=$value');
            }
          });
        }
      }
      
      if (cookiePairs.isEmpty) {
        return {
          'success': false,
          'error': 'Format cookies tidak valid atau kosong',
        };
      }
      
      final cookieString = cookiePairs.join('; ');
      await saveCookies(cookieString);
      
      // Verify cookies dengan check login
      final isLoggedIn = await checkLoginStatus();
      
      return {
        'success': true,
        'message': 'Cookies berhasil diimport',
        'isLoggedIn': isLoggedIn,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error parsing JSON: $e',
      };
    }
  }
  
  // Fetch game tags dari API (sama seperti source code Python)
  static Future<Map<String, String>> fetchGameTags() async {
    try {
      // Gunakan base URL yang sama dengan source code Python
      final url = 'https://webcast16-normal-c-useast2a.tiktokv.com/webcast/room/hashtag/list/';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final gameTagList = data['data']['game_tag_list'] as List;
        
        // Convert ke Map: id -> show_name
        final Map<String, String> games = {};
        for (var game in gameTagList) {
          final id = game['id']?.toString() ?? '';
          final name = game['show_name']?.toString() ?? '';
          if (id.isNotEmpty && name.isNotEmpty) {
            games[id] = name;
          }
        }
        
        return games;
      }
      
      return {};
    } catch (e) {
      print('Error fetching game tags: $e');
      return {};
    }
  }
  
  // Import cookies dari Netscape format (opsional)
  static Future<Map<String, dynamic>> importCookiesFromNetscape(String netscapeString) async {
    try {
      final List<String> cookiePairs = [];
      final lines = netscapeString.split('\n');
      
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#') || line.startsWith('HttpOnly')) {
          continue;
        }
        
        // Format Netscape: domain, flag, path, secure, expiration, name, value
        final parts = line.split('\t');
        if (parts.length >= 7) {
          final name = parts[5].trim();
          final value = parts[6].trim();
          if (name.isNotEmpty && value.isNotEmpty) {
            cookiePairs.add('$name=$value');
          }
        }
      }
      
      if (cookiePairs.isEmpty) {
        return {
          'success': false,
          'error': 'Format Netscape cookies tidak valid',
        };
      }
      
      final cookieString = cookiePairs.join('; ');
      await saveCookies(cookieString);
      
      final isLoggedIn = await checkLoginStatus();
      
      return {
        'success': true,
        'message': 'Cookies berhasil diimport',
        'isLoggedIn': isLoggedIn,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error parsing Netscape format: $e',
      };
    }
  }
}

