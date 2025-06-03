import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class with common test utilities
class TestUtils {
  /// Finds a specific widget by text and scrolls until it's visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    String text, {
    Key? scrollableKey,
    double delta = 100,
  }) async {
    final finder = find.text(text);

    final scrollable = find.byType(Scrollable);
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable:
          scrollableKey != null ? find.byKey(scrollableKey) : scrollable,
    );
  }

  /// Takes a screenshot (useful when running on a real device)
  static Future<void> takeScreenshot(WidgetTester tester, String name) async {
    await tester.pumpAndSettle();
    // This is just a placeholder - actual screenshot functionality
    // would require platform-specific implementations
    print('Taking screenshot: $name');
  }
}
