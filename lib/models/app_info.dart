class AppInfo {
  final bool showAds;
  final bool allowVideoCall;
  final bool allowVoiceCall;

  AppInfo({
    this.showAds = false,
    this.allowVideoCall = true,
    this.allowVoiceCall = true,
  });


  factory AppInfo.fromMap(Map<String, dynamic> data) {
    final AppInfo defaults = AppInfo();
    return AppInfo(
      showAds: data['showAds'] ?? defaults.showAds,
      allowVideoCall: data['allowVideoCall'] ?? defaults.allowVideoCall,
      allowVoiceCall: data['allowVoiceCall'] ?? defaults.allowVoiceCall,
    );
  }
}
