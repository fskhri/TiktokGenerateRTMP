import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'TikTok RTMP Generator',
      'welcome': 'Welcome',
      'welcomeMessage': 'Please login to TikTok to start generating RTMP keys',
      'loginTikTok': 'Login TikTok',
      'importCookies': 'Import Cookies from File',
      'cookiesNote': 'Note: Cookies will be saved permanently after import. No need to import again every time you open the app.',
      'login': 'Login',
      'logout': 'Logout',
      'logoutConfirm': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'cookiesInfo': 'Cookies Info',
      'cookiesLoaded': 'Cookies are loaded',
      'cookiesNotFound': 'Cookies not found',
      'changeCookies': 'Change Cookies',
      'title': 'Title',
      'topic': 'Topic',
      'game': 'Game',
      'selectGame': 'Select Game (optional)',
      'none': 'None',
      'region': 'Region',
      'streamType': 'Stream Type',
      'enableReplay': 'Enable Replay',
      'closeRoomWhenStreamEnds': 'Close Room When Stream Ends',
      'ageRestricted': 'Age Restricted',
      'thumbnail': 'Thumbnail (Optional)',
      'selectFromGallery': 'Select from Gallery',
      'changeThumbnail': 'Change Thumbnail',
      'removeThumbnail': 'Remove thumbnail',
      'goLive': 'Go Live',
      'endStream': 'End Stream',
      'baseUrl': 'Base URL',
      'streamKey': 'Stream Key',
      'shareUrl': 'Share URL',
      'roomId': 'Room ID',
      'copy': 'Copy',
      'copied': 'Copied!',
      'generating': 'Generating...',
      'streamKeyGenerated': 'Stream key generated successfully!',
      'error': 'Error',
      'titleRequired': 'Stream title cannot be empty',
      'loginSuccess': 'Login successful! Cookies saved.',
      'loginFailed': 'Failed to get cookies. Please make sure you are logged in correctly.',
      'cookiesImported': 'Cookies imported successfully',
      'importCookiesTitle': 'Import Cookies',
      'pasteCookies': 'Paste cookies.json content here:',
      'pasteJsonCookies': 'Paste JSON cookies here...',
      'import': 'Import',
      'selectCookiesFile': 'Select cookies.json file',
      'errorSelectingThumbnail': 'Error selecting thumbnail',
      'errorReadingFile': 'Error reading file',
      'pleaseLoginFirst': 'Please login first',
      'cookiesSavedIncomplete': 'Cookies saved, but may be incomplete. Try importing from file if error occurs.',
      'cookiesSaved': 'Cookies saved, but not complete. Import from file for best results.',
      'cannotGetCookies': 'Cannot get cookies. Try importing from cookies.json file.',
    },
    'id': {
      'appTitle': 'TikTok RTMP Generator',
      'welcome': 'Selamat Datang',
      'welcomeMessage': 'Silakan login ke TikTok untuk mulai generate RTMP key',
      'loginTikTok': 'Login TikTok',
      'importCookies': 'Import Cookies dari File',
      'cookiesNote': 'Catatan: Cookies akan tersimpan permanen setelah di-import. Tidak perlu import lagi setiap kali buka aplikasi.',
      'login': 'Login',
      'logout': 'Logout',
      'logoutConfirm': 'Apakah Anda yakin ingin logout?',
      'cancel': 'Batal',
      'cookiesInfo': 'Cookies Info',
      'cookiesLoaded': 'Cookies are loaded',
      'cookiesNotFound': 'Cookies tidak ditemukan',
      'changeCookies': 'Ganti Cookies',
      'title': 'Title',
      'topic': 'Topic',
      'game': 'Game',
      'selectGame': 'Pilih Game (opsional)',
      'none': 'None',
      'region': 'Region',
      'streamType': 'Stream Type',
      'enableReplay': 'Enable Replay',
      'closeRoomWhenStreamEnds': 'Close Room When Stream Ends',
      'ageRestricted': 'Age Restricted',
      'thumbnail': 'Thumbnail (Opsional)',
      'selectFromGallery': 'Pilih dari Gallery',
      'changeThumbnail': 'Ganti Thumbnail',
      'removeThumbnail': 'Hapus thumbnail',
      'goLive': 'Go Live',
      'endStream': 'End Stream',
      'baseUrl': 'Base URL',
      'streamKey': 'Stream Key',
      'shareUrl': 'Share URL',
      'roomId': 'Room ID',
      'copy': 'Copy',
      'copied': 'Copied!',
      'generating': 'Generating...',
      'streamKeyGenerated': 'Stream key berhasil di-generate!',
      'error': 'Error',
      'titleRequired': 'Judul stream tidak boleh kosong',
      'loginSuccess': 'Login berhasil! Cookies tersimpan.',
      'loginFailed': 'Tidak dapat mengambil cookies. Pastikan Anda sudah login dengan benar.',
      'cookiesImported': 'Cookies berhasil diimport',
      'importCookiesTitle': 'Import Cookies',
      'pasteCookies': 'Paste isi file cookies.json di sini:',
      'pasteJsonCookies': 'Paste JSON cookies di sini...',
      'import': 'Import',
      'selectCookiesFile': 'Pilih file cookies.json',
      'errorSelectingThumbnail': 'Error memilih thumbnail',
      'errorReadingFile': 'Error membaca file',
      'pleaseLoginFirst': 'Silakan login terlebih dahulu',
      'cookiesSavedIncomplete': 'Cookies tersimpan, tapi mungkin tidak lengkap. Coba import dari file jika error.',
      'cookiesSaved': 'Cookies tersimpan, tapi tidak lengkap. Import dari file untuk hasil terbaik.',
      'cannotGetCookies': 'Tidak dapat mengambil cookies. Coba import dari file cookies.json.',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }

  // Getters for common strings
  String get appTitle => translate('appTitle');
  String get welcome => translate('welcome');
  String get welcomeMessage => translate('welcomeMessage');
  String get loginTikTok => translate('loginTikTok');
  String get importCookies => translate('importCookies');
  String get cookiesNote => translate('cookiesNote');
  String get login => translate('login');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logoutConfirm');
  String get cancel => translate('cancel');
  String get cookiesInfo => translate('cookiesInfo');
  String get cookiesLoaded => translate('cookiesLoaded');
  String get cookiesNotFound => translate('cookiesNotFound');
  String get changeCookies => translate('changeCookies');
  String get title => translate('title');
  String get topic => translate('topic');
  String get game => translate('game');
  String get selectGame => translate('selectGame');
  String get none => translate('none');
  String get region => translate('region');
  String get streamType => translate('streamType');
  String get enableReplay => translate('enableReplay');
  String get closeRoomWhenStreamEnds => translate('closeRoomWhenStreamEnds');
  String get ageRestricted => translate('ageRestricted');
  String get thumbnail => translate('thumbnail');
  String get selectFromGallery => translate('selectFromGallery');
  String get changeThumbnail => translate('changeThumbnail');
  String get removeThumbnail => translate('removeThumbnail');
  String get goLive => translate('goLive');
  String get endStream => translate('endStream');
  String get baseUrl => translate('baseUrl');
  String get streamKey => translate('streamKey');
  String get shareUrl => translate('shareUrl');
  String get roomId => translate('roomId');
  String get copy => translate('copy');
  String get copied => translate('copied');
  String get generating => translate('generating');
  String get streamKeyGenerated => translate('streamKeyGenerated');
  String get error => translate('error');
  String get titleRequired => translate('titleRequired');
  String get loginSuccess => translate('loginSuccess');
  String get loginFailed => translate('loginFailed');
  String get cookiesImported => translate('cookiesImported');
  String get importCookiesTitle => translate('importCookiesTitle');
  String get pasteCookies => translate('pasteCookies');
  String get pasteJsonCookies => translate('pasteJsonCookies');
  String get import => translate('import');
  String get selectCookiesFile => translate('selectCookiesFile');
  String get errorSelectingThumbnail => translate('errorSelectingThumbnail');
  String get errorReadingFile => translate('errorReadingFile');
  String get pleaseLoginFirst => translate('pleaseLoginFirst');
  String get cookiesSavedIncomplete => translate('cookiesSavedIncomplete');
  String get cookiesSaved => translate('cookiesSaved');
  String get cannotGetCookies => translate('cannotGetCookies');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

