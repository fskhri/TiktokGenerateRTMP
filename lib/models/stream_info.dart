class StreamInfo {
  final String fullRtmpUrl;
  final String baseUrl;
  final String streamKey;
  final String shareUrl;
  final String roomId;
  
  StreamInfo({
    required this.fullRtmpUrl,
    required this.baseUrl,
    required this.streamKey,
    required this.shareUrl,
    required this.roomId,
  });
  
  factory StreamInfo.fromMap(Map<String, dynamic> map) {
    return StreamInfo(
      fullRtmpUrl: map['fullRtmpUrl'] ?? map['baseUrl'] + map['streamKey'] ?? '',
      baseUrl: map['baseUrl'] ?? '',
      streamKey: map['streamKey'] ?? '',
      shareUrl: map['shareUrl'] ?? '',
      roomId: map['roomId'] ?? '',
    );
  }
}

