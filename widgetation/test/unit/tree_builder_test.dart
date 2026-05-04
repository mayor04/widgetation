import 'package:flutter_test/flutter_test.dart';
import 'package:widgetation/src/tree_builder.dart';

void main() {
  group('isExternalWidgetFile', () {
    test('null is external (no creation-location data)', () {
      expect(isExternalWidgetFile(null), isTrue);
    });

    test('package: scheme for flutter SDK is external', () {
      expect(isExternalWidgetFile('package:flutter/src/widgets/text.dart'),
          isTrue);
    });

    test('file URI under /packages/flutter/ is external', () {
      expect(
          isExternalWidgetFile(
              'file:///opt/flutter/packages/flutter/lib/src/widgets/text.dart'),
          isTrue);
    });

    test('any path under .pub-cache is external', () {
      expect(
          isExternalWidgetFile(
              '/Users/me/.pub-cache/hosted/pub.dev/forui-0.19.0/lib/foo.dart'),
          isTrue);
    });

    test('alternative pub-cache spelling is external', () {
      expect(isExternalWidgetFile('/var/pub-cache/hosted/pkg/lib/foo.dart'),
          isTrue);
    });

    test('user file in workspace is internal', () {
      expect(isExternalWidgetFile('/Users/me/project/lib/main.dart'), isFalse);
    });

    test('package-prefixed path that is NOT flutter is internal', () {
      // `package:foo/...` doesn't pattern-match the flutter prefix.
      expect(isExternalWidgetFile('package:my_app/widgets/home.dart'), isFalse);
    });
  });
}
