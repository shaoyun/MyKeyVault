import 'package:flutter/foundation.dart';

class TimeSync {
  /// 获取本机UTC时间戳（毫秒）
  static int getSyncedTimestamp() {
    return DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  /// 获取本机UTC秒时间戳
  static int getSyncedTimestampSeconds() {
    return getSyncedTimestamp() ~/ 1000;
  }

  /// 获取时间信息（用于调试）
  static Map<String, dynamic> getTimeDifferenceInfo() {
    final now = DateTime.now();
    final utcNow = now.toUtc();
    return {
      'hasTimeDifference': false,
      'timeDifferenceSeconds': 0,
      'localTime': now.toIso8601String(),
      'utcTime': utcNow.toIso8601String(),
      'syncedTime': utcNow.toIso8601String(),
      'timestamp': getSyncedTimestampSeconds(),
    };
  }
}