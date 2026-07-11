import 'package:foundation/foundation.dart';
import 'package:foundation/testing.dart';
import 'package:test/test.dart';

void main() {
  test('FakeLogger 依序記錄各層級', () {
    final logger = FakeLogger()
      ..debug('d')
      ..info('i')
      ..warning('w')
      ..error('e', error: 'boom');

    expect(logger.records, hasLength(4));
    expect(logger.records[0].level, LogLevel.debug);
    expect(logger.records[1].level, LogLevel.info);
    expect(logger.records[2].level, LogLevel.warning);
    expect(logger.records[3].level, LogLevel.error);
    expect(logger.records[3].message, 'e');
    expect(logger.records[3].error, 'boom');
  });

  test('FakeLogger 可當 AppLogger 注入', () {
    final AppLogger logger = FakeLogger()..info('polymorphic');
    expect((logger as FakeLogger).records.single.message, 'polymorphic');
  });
}
