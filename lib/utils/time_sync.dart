import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class TimeSync {
  static DateTime? _serverTime;
  static DateTime? _localTime;
  static Duration? _timeDifference;

  /// 获取同步后的时间戳（毫秒）
  static int getSyncedTimestamp() {
    if (_timeDifference != null) {
      // 使用同步后的时间
      return DateTime.now().add(_timeDifference!).toUtc().millisecondsSinceEpoch;
    }
    // 回退到本地UTC时间
    return DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  /// 获取同步后的UTC秒时间戳
  static int getSyncedTimestampSeconds() {
    return getSyncedTimestamp() ~/ 1000;
  }

  /// 同步网络时间
  static Future<bool> syncTime() async {
    try {
      // 尝试多个时间服务器
      final servers = [
        'timeapi.io',
        'time.is',
        'ntp.pool',
      ];

      for (final server in servers) {
        if (await _syncFromServer(server)) {
          if (kDebugMode) {
            print('Time synced successfully from $server');
            if (_timeDifference != null) {
              print('Time difference: ${_timeDifference!.inSeconds} seconds');
            }
          }
          return true;
        }
      }
      
      if (kDebugMode) {
        print('Failed to sync time from all servers, using local time');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Time sync error: $e');
      }
      return false;
    }
  }

  /// 从指定服务器同步时间
  static Future<bool> _syncFromServer(String server) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      
      HttpClientRequest request;
      String url;
      
      switch (server) {
        case 'timeapi.io':
          url = 'http://timeapi.io/api/Time/current/zone?timeZone=UTC';
          break;
        case 'time.is':
          url = 'https://time.is/Unix_time_now';
          break;
        case 'ntp.pool':
          // 使用本地时间，但添加NTP服务器是为了将来扩展
          _localTime = DateTime.now().toUtc();
          _serverTime = _localTime;
          _timeDifference = Duration.zero;
          return true;
        default:
          return false;
      }

      final uri = Uri.parse(url);
      request = await client.getUrl(uri);
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        
        // time.is返回的是HTML而不是JSON
        if (server == 'time.is') {
          // 处理HTML响应
          final regex = RegExp(r'id="unix_time">(\d+)<');
          final match = regex.firstMatch(responseBody);
          if (match != null && match.groupCount >= 1) {
            final unixTime = int.parse(match.group(1)!);
            final serverTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000, isUtc: true);
            _localTime = DateTime.now().toUtc();
            _serverTime = serverTime;
            _timeDifference = _serverTime!.difference(_localTime!);
            client.close();
            return true;
          }
          client.close();
          return false;
        }
        
        // 其他服务器返回JSON
        final data = jsonDecode(responseBody);
        
        DateTime? serverTime;
        
        // 只处理timeapi.io，time.is已经在前面处理过了
        if (server == 'timeapi.io') {
          serverTime = DateTime.parse(data['dateTime']);
        }
        
        if (serverTime != null) {
          _localTime = DateTime.now().toUtc();
          _serverTime = serverTime.toUtc();
          _timeDifference = _serverTime!.difference(_localTime!);
          
          client.close();
          return true;
        }
      }
      
      client.close();
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing from $server: $e');
      }
      return false;
    }
  }

  /// 获取时间差信息（用于调试）
  static Map<String, dynamic> getTimeDifferenceInfo() {
    return {
      'hasTimeDifference': _timeDifference != null,
      'timeDifferenceSeconds': _timeDifference?.inSeconds ?? 0,
      'serverTime': _serverTime?.toIso8601String(),
      'localTime': _localTime?.toIso8601String(),
      'syncedTime': DateTime.fromMillisecondsSinceEpoch(getSyncedTimestamp()).toUtc().toIso8601String(),
    };
  }

  /// 重置时间同步
  static void reset() {
    _serverTime = null;
    _localTime = null;
    _timeDifference = null;
  }
}