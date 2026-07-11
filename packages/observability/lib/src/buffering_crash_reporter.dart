import 'package:observability/src/crash_reporter.dart';

/// 啟動期緩衝的 crash reporter(spec §10 第 3 條)。
///
/// bootstrap 在第 3 步就掛錯誤捕捉,但 Firebase 要到第 4 步才 init;
/// 期間的錯誤先緩衝,attach 真正的 reporter 後依序補送。
class BufferingCrashReporter implements CrashReporter {
  static const _capacity = 100;

  final List<Future<void> Function(CrashReporter r)> _buffer = [];
  CrashReporter? _delegate;

  /// 掛上真正的 reporter 並 flush 緩衝(依原順序)。
  void attach(CrashReporter delegate) {
    _delegate = delegate;
    for (final replay in _buffer) {
      // 依序補送;不 await,避免 attach 被上報 IO 卡住。
      // ignore: discarded_futures -- 補送為 fire-and-forget,失敗不影響啟動
      replay(delegate);
    }
    _buffer.clear();
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) async {
    final delegate = _delegate;
    if (delegate != null) {
      return delegate.recordError(error, stackTrace, fatal: fatal);
    }
    _push((r) => r.recordError(error, stackTrace, fatal: fatal));
  }

  @override
  Future<void> setUserId(String? userId) async {
    final delegate = _delegate;
    if (delegate != null) {
      return delegate.setUserId(userId);
    }
    _push((r) => r.setUserId(userId));
  }

  @override
  Future<void> log(String message) async {
    final delegate = _delegate;
    if (delegate != null) {
      return delegate.log(message);
    }
    _push((r) => r.log(message));
  }

  void _push(Future<void> Function(CrashReporter r) replay) {
    if (_buffer.length >= _capacity) {
      _buffer.removeAt(0);
    }
    _buffer.add(replay);
  }
}
