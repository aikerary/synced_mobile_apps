import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestUtils {
  /// Find a widget by text and scrolls until it's visible
  static Future<void> scrollToFind(
    WidgetTester tester,
    String text, {
    Finder? scrollable,
    double dx = 0.0,
    double dy = -300.0,
    int maxSwipes = 10,
  }) async {
    scrollable ??= find.byType(Scrollable);

    for (int i = 0; i < maxSwipes; i++) {
      if (find.text(text).evaluate().isNotEmpty) {
        // If found, break the loop
        break;
      }

      // Scroll down
      await tester.drag(scrollable.first, Offset(dx, dy));
      await tester.pumpAndSettle();
    }

    // Verify we found the widget - accept multiple matches
    expect(find.text(text), findsWidgets,
        reason: 'Text "$text" was not found after scrolling');
  }

  /// Find unique text that should only appear once
  static Future<void> verifyUniqueTextExists(
    WidgetTester tester,
    String text,
  ) async {
    final finder = find.text(text);
    expect(finder, findsOneWidget,
        reason: 'Expected unique text "$text" not found');
  }

  /// Find text that might appear multiple times
  static Future<void> verifyTextExists(
    WidgetTester tester,
    String text,
  ) async {
    final finder = find.text(text);
    expect(finder, findsWidgets, reason: 'Text "$text" not found');
  }

  /// Takes a screenshot if running on a device that supports it
  static Future<void> captureScreenshot(String name) async {
    // This is a placeholder - actual implementation would depend on platform
    print('Would capture screenshot: $name');
  }

  /// Waits for a specific widget to appear with timeout
  static Future<bool> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final DateTime start = DateTime.now();
    bool found = false;

    while (DateTime.now().difference(start) < timeout) {
      await tester.pump(const Duration(milliseconds: 100));

      if (finder.evaluate().isNotEmpty) {
        found = true;
        break;
      }
    }

    return found;
  }

  /// Finds and taps a button with specific text
  static Future<void> tapButton(
    WidgetTester tester,
    String buttonText, {
    bool scrollToButton = true,
  }) async {
    if (scrollToButton) {
      await scrollToFind(tester, buttonText);
    }

    await tester.tap(find.text(buttonText).first);
    await tester.pumpAndSettle();
  }

  /// Safely tap on a widget that might not be present
  static Future<bool> safelyTap(
    WidgetTester tester,
    Finder finder,
  ) async {
    try {
      if (finder.evaluate().isNotEmpty) {
        await tester.tap(finder.first);
        await tester.pumpAndSettle();
        return true;
      }
    } catch (e) {
      print('Could not tap: $e');
    }
    return false;
  }
}
