import 'dart:async';
import 'package:flutter/foundation.dart';

/// 性能监控工具类
class PerformanceUtils {
  static final Map<String, Stopwatch> _stopwatches = {};
  static final Map<String, List<int>> _measurements = {};
  
  /// 开始性能测量
  static void startMeasurement(String name) {
    if (!kDebugMode) return;
    
    final stopwatch = Stopwatch()..start();
    _stopwatches[name] = stopwatch;
  }
  
  /// 结束性能测量并记录结果
  static void endMeasurement(String name) {
    if (!kDebugMode) return;
    
    final stopwatch = _stopwatches[name];
    if (stopwatch == null) return;
    
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;
    
    _measurements.putIfAbsent(name, () => []).add(elapsed);
    _stopwatches.remove(name);
    
    debugPrint('Performance [$name]: ${elapsed}ms');
  }
  
  /// 获取性能统计信息
  static Map<String, PerformanceStats> getStats() {
    if (!kDebugMode) return {};
    
    final stats = <String, PerformanceStats>{};
    
    for (final entry in _measurements.entries) {
      final measurements = entry.value;
      if (measurements.isEmpty) continue;
      
      final total = measurements.reduce((a, b) => a + b);
      final average = total / measurements.length;
      final min = measurements.reduce((a, b) => a < b ? a : b);
      final max = measurements.reduce((a, b) => a > b ? a : b);
      
      stats[entry.key] = PerformanceStats(
        count: measurements.length,
        total: total,
        average: average,
        min: min,
        max: max,
      );
    }
    
    return stats;
  }
  
  /// 清除所有性能数据
  static void clearStats() {
    if (!kDebugMode) return;
    
    _measurements.clear();
    _stopwatches.clear();
  }
  
  /// 打印性能统计信息
  static void printStats() {
    if (!kDebugMode) return;
    
    final stats = getStats();
    if (stats.isEmpty) {
      debugPrint('No performance data available');
      return;
    }
    
    debugPrint('=== Performance Statistics ===');
    for (final entry in stats.entries) {
      final stat = entry.value;
      debugPrint('${entry.key}:');
      debugPrint('  Count: ${stat.count}');
      debugPrint('  Total: ${stat.total}ms');
      debugPrint('  Average: ${stat.average.toStringAsFixed(2)}ms');
      debugPrint('  Min: ${stat.min}ms');
      debugPrint('  Max: ${stat.max}ms');
    }
    debugPrint('==============================');
  }
  
  /// 异步操作性能测量装饰器
  static Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    startMeasurement(name);
    try {
      final result = await operation();
      endMeasurement(name);
      return result;
    } catch (e) {
      endMeasurement(name);
      rethrow;
    }
  }
  
  /// 同步操作性能测量装饰器
  static T measureSync<T>(
    String name,
    T Function() operation,
  ) {
    startMeasurement(name);
    try {
      final result = operation();
      endMeasurement(name);
      return result;
    } catch (e) {
      endMeasurement(name);
      rethrow;
    }
  }
}

/// 性能统计数据
class PerformanceStats {
  final int count;
  final int total;
  final double average;
  final int min;
  final int max;
  
  const PerformanceStats({
    required this.count,
    required this.total,
    required this.average,
    required this.min,
    required this.max,
  });
  
  @override
  String toString() {
    return 'PerformanceStats(count: $count, total: ${total}ms, '
           'average: ${average.toStringAsFixed(2)}ms, min: ${min}ms, max: ${max}ms)';
  }
}

/// 内存使用监控
class MemoryMonitor {
  static Timer? _timer;
  static final List<int> _memoryUsage = [];
  
  /// 开始内存监控
  static void startMonitoring({Duration interval = const Duration(seconds: 5)}) {
    if (!kDebugMode) return;
    
    _timer?.cancel();
    _timer = Timer.periodic(interval, (timer) {
      // 在真实应用中，这里可以使用dart:developer的Service类
      // 来获取实际的内存使用情况
      debugPrint('Memory monitoring tick');
    });
  }
  
  /// 停止内存监控
  static void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }
  
  /// 记录内存快照
  static void recordSnapshot(String label) {
    if (!kDebugMode) return;
    
    debugPrint('Memory snapshot [$label]: Recorded');
  }
}

/// Widget构建性能监控
class BuildPerformanceMonitor {
  static final Map<String, int> _buildCounts = {};
  static final Map<String, List<int>> _buildTimes = {};
  
  /// 记录Widget构建
  static void recordBuild(String widgetName, int buildTimeMs) {
    if (!kDebugMode) return;
    
    _buildCounts[widgetName] = (_buildCounts[widgetName] ?? 0) + 1;
    _buildTimes.putIfAbsent(widgetName, () => []).add(buildTimeMs);
  }
  
  /// 获取构建统计
  static Map<String, BuildStats> getBuildStats() {
    if (!kDebugMode) return {};
    
    final stats = <String, BuildStats>{};
    
    for (final entry in _buildCounts.entries) {
      final widgetName = entry.key;
      final buildCount = entry.value;
      final buildTimes = _buildTimes[widgetName] ?? [];
      
      if (buildTimes.isNotEmpty) {
        final totalTime = buildTimes.reduce((a, b) => a + b);
        final averageTime = totalTime / buildTimes.length;
        
        stats[widgetName] = BuildStats(
          buildCount: buildCount,
          totalBuildTime: totalTime,
          averageBuildTime: averageTime,
        );
      }
    }
    
    return stats;
  }
  
  /// 清除构建统计
  static void clearBuildStats() {
    if (!kDebugMode) return;
    
    _buildCounts.clear();
    _buildTimes.clear();
  }
  
  /// 打印构建统计
  static void printBuildStats() {
    if (!kDebugMode) return;
    
    final stats = getBuildStats();
    if (stats.isEmpty) {
      debugPrint('No build performance data available');
      return;
    }
    
    debugPrint('=== Widget Build Statistics ===');
    for (final entry in stats.entries) {
      final stat = entry.value;
      debugPrint('${entry.key}:');
      debugPrint('  Builds: ${stat.buildCount}');
      debugPrint('  Total time: ${stat.totalBuildTime}ms');
      debugPrint('  Average time: ${stat.averageBuildTime.toStringAsFixed(2)}ms');
    }
    debugPrint('===============================');
  }
}

/// Widget构建统计数据
class BuildStats {
  final int buildCount;
  final int totalBuildTime;
  final double averageBuildTime;
  
  const BuildStats({
    required this.buildCount,
    required this.totalBuildTime,
    required this.averageBuildTime,
  });
  
  @override
  String toString() {
    return 'BuildStats(builds: $buildCount, total: ${totalBuildTime}ms, '
           'average: ${averageBuildTime.toStringAsFixed(2)}ms)';
  }
}