import 'package:flutter_test/flutter_test.dart';
import 'package:observability/observability.dart';
import 'package:observability/testing.dart';

void main() {
  test('attach 前緩衝,attach 時依序 flush,之後直通', () async {
    final buffering = BufferingCrashReporter();
    await buffering.recordError('e1', StackTrace.empty);
    await buffering.log('m1');
    await buffering.setUserId('u1');

    final delegate = FakeCrashReporter();
    buffering.attach(delegate);
    expect(delegate.recordedErrors, hasLength(1));
    expect(delegate.logs, ['m1']);
    expect(delegate.userIds, ['u1']);

    await buffering.recordError('e2', null);
    expect(delegate.recordedErrors, hasLength(2));
  });

  test('緩衝上限 100 筆,超出丟最舊', () async {
    final buffering = BufferingCrashReporter();
    for (var i = 0; i < 105; i++) {
      await buffering.log('m$i');
    }
    final delegate = FakeCrashReporter();
    buffering.attach(delegate);
    expect(delegate.logs, hasLength(100));
    expect(delegate.logs.first, 'm5');
  });
}
