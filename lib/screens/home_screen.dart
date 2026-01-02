import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../services/tiktok_service.dart';
import '../models/stream_info.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onCookiesImported;
  
  const HomeScreen({super.key, this.onCookiesImported});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _titleController = TextEditingController(text: 'Test Stream');
  final _thumbnailController = TextEditingController();
  final _gameTagController = TextEditingController();
  String? _selectedTopic;
  String _regionPriority = 'id';
  String _streamType = 'no_spoofing';
  bool _enableReplay = false;
  bool _closeRoomWhenStreamEnds = true;
  bool _isMatureContent = false;
  bool _isGenerating = false;
  StreamInfo? _streamInfo;
  bool _cookiesLoaded = false;

  final List<Map<String, String?>> _topicOptions = [
    {'value': null, 'label': 'None'},
    {'value': 'chat_interview', 'label': 'Chat & Interview'},
    {'value': 'gaming', 'label': 'Gaming'},
    {'value': 'music', 'label': 'Music'},
    {'value': 'dance', 'label': 'Dance'},
    {'value': 'beauty', 'label': 'Beauty'},
    {'value': 'fashion', 'label': 'Fashion'},
    {'value': 'food', 'label': 'Food'},
    {'value': 'sports', 'label': 'Sports'},
    {'value': 'travel', 'label': 'Travel'},
    {'value': 'education', 'label': 'Education'},
  ];

  final List<Map<String, String>> _regionOptions = [
    {'value': 'id', 'label': 'Indonesia'},
    {'value': 'default', 'label': 'Default'},
    {'value': 'US', 'label': 'United States'},
    {'value': 'GB', 'label': 'United Kingdom'},
    {'value': 'CA', 'label': 'Canada'},
    {'value': 'AU', 'label': 'Australia'},
    {'value': 'DE', 'label': 'Germany'},
    {'value': 'FR', 'label': 'France'},
    {'value': 'JP', 'label': 'Japan'},
    {'value': 'KR', 'label': 'South Korea'},
  ];

  @override
  void initState() {
    super.initState();
    _checkCookiesStatus();
    // Listen untuk perubahan cookies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCookiesStatus();
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh cookies status saat widget di-update
    _checkCookiesStatus();
  }

  Future<void> _checkCookiesStatus() async {
    final cookies = await TikTokService.getCookies();
    setState(() {
      _cookiesLoaded = cookies != null && cookies.isNotEmpty;
    });
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
          await _checkCookiesStatus();
          
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
          await _checkCookiesStatus();
          
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
  void dispose() {
    _titleController.dispose();
    _thumbnailController.dispose();
    _gameTagController.dispose();
    super.dispose();
  }

  Future<void> _generateStreamKey() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul stream tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Convert topic to hashtag_id
    String? hashtagId;
    String? gameTagId;
    
    if (_selectedTopic != null) {
      // Map topic to hashtag_id sesuai source code Python
      final topicMap = {
        'chat_interview': '42',
        'gaming': '5',
        'music': '6',
        'dance': '3',
        'beauty': '9',
        'fashion': '9',
        'food': '4',
        'sports': '13',
        'travel': null,
        'education': '45',
      };
      hashtagId = topicMap[_selectedTopic];
      
      // Jika gaming, perlu game_tag_id
      if (_selectedTopic == 'gaming' && _gameTagController.text.trim().isNotEmpty) {
        gameTagId = _gameTagController.text.trim();
      } else {
        gameTagId = '0';
      }
    } else {
      hashtagId = '42'; // Default: Chat & Interview
      gameTagId = '0';
    }
    
    final result = await TikTokService.generateStreamKey(
      title: _titleController.text.trim(),
      hashtagId: hashtagId,
      gameTagId: gameTagId,
      enableReplay: _enableReplay,
      closeRoomWhenStreamEnds: _closeRoomWhenStreamEnds,
      regionPriority: _regionPriority == 'default' ? '' : _regionPriority,
      isMatureContent: _isMatureContent,
    );

    setState(() {
      _isGenerating = false;
    });

    if (result['success'] == true) {
      setState(() {
        _streamInfo = StreamInfo.fromMap(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stream key berhasil di-generate!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMsg = result['error'] ?? 'Unknown error';
      final fullError = result['fullError'] ?? '';
      
      // Tampilkan dialog dengan error detail
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error Generate Stream Key'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorMsg,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (fullError.isNotEmpty && fullError != errorMsg) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Detail Error:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fullError,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              if (fullError.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: fullError));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error detail disalin ke clipboard')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Copy Error'),
                ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label berhasil disalin!')),
      );
    }
  }

  Future<void> _endStream() async {
    if (_streamInfo == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Stream'),
        content: const Text('Apakah Anda yakin ingin mengakhiri stream?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Stream'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await TikTokService.endStream(_streamInfo!.roomId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Stream berhasil diakhiri'
                : 'Gagal mengakhiri stream'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          setState(() {
            _streamInfo = null;
          });
        }
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TikTokService.saveCookies('');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TikTok RTMP Generator'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cookies Info Section
            Card(
              color: _cookiesLoaded ? Colors.green.shade50 : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cookies Info',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _cookiesLoaded ? 'Cookies are loaded' : 'Cookies tidak ditemukan',
                            style: TextStyle(
                              fontSize: 14,
                              color: _cookiesLoaded ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _importCookies,
                      tooltip: 'Ganti Cookies',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Topic
                          DropdownButtonFormField<String?>(
                            value: _selectedTopic,
                            decoration: const InputDecoration(
                              labelText: 'Topic',
                              border: OutlineInputBorder(),
                            ),
                            items: _topicOptions.map((option) {
                              return DropdownMenuItem(
                                value: option['value'],
                                child: Text(option['label']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTopic = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Game Tag ID (hanya muncul jika Topic = Gaming)
                          if (_selectedTopic == 'gaming') ...[
                            TextField(
                              controller: _gameTagController,
                              decoration: const InputDecoration(
                                labelText: 'Game Tag ID',
                                border: OutlineInputBorder(),
                                hintText: 'Masukkan Game Tag ID (opsional)',
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // Region
                          DropdownButtonFormField<String>(
                            value: _regionPriority,
                            decoration: const InputDecoration(
                              labelText: 'Region',
                              border: OutlineInputBorder(),
                            ),
                            items: _regionOptions.map((option) {
                              return DropdownMenuItem(
                                value: option['value'],
                                child: Text(option['label']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _regionPriority = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Stream Type
                          const Text(
                            'Stream Type',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          RadioListTile<String>(
                            title: const Text('No Spoofing'),
                            value: 'no_spoofing',
                            groupValue: _streamType,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _streamType = value;
                                });
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<String>(
                            title: const Text('Mobile Camera Stream (gets no traffic)'),
                            value: 'mobile_camera',
                            groupValue: _streamType,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _streamType = value;
                                });
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                          RadioListTile<String>(
                            title: const Text('Mobile Screenshare (gets no traffic)'),
                            value: 'mobile_screenshare',
                            groupValue: _streamType,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _streamType = value;
                                });
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 8),
                          
                          // Checkboxes
                          CheckboxListTile(
                            title: const Text('Generate Replay'),
                            value: _enableReplay,
                            onChanged: (value) {
                              setState(() {
                                _enableReplay = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: const Text('Close Room When Close Stream'),
                            value: _closeRoomWhenStreamEnds,
                            onChanged: (value) {
                              setState(() {
                                _closeRoomWhenStreamEnds = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: const Text('Age Restricted'),
                            value: _isMatureContent,
                            onChanged: (value) {
                              setState(() {
                                _isMatureContent = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 16),
                          
                          // Selected Thumbnail
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _thumbnailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Selected Thumbnail:',
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  // TODO: Implement thumbnail picker
                                },
                                child: const Text('Browse'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            
            const SizedBox(height: 16),
            
            // Outputs Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Outputs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_streamInfo != null) ...[
                      _buildOutputField('RTMP URL', _streamInfo!.fullRtmpUrl),
                      const SizedBox(height: 12),
                      _buildOutputField('Share URL', _streamInfo!.shareUrl),
                    ] else ...[
                      _buildOutputField('RTMP URL', ''),
                      const SizedBox(height: 12),
                      _buildOutputField('Share URL', ''),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateStreamKey,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(_isGenerating ? 'Generating...' : 'Go Live'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _streamInfo != null ? _endStream : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('End Live'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputField(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            readOnly: true,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: value.isNotEmpty
              ? () => _copyToClipboard(value, label)
              : null,
          tooltip: 'Copy',
        ),
      ],
    );
  }
}

