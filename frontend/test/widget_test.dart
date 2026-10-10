import 'package:flutter_test/flutter_test.dart';
import 'package:shop_lite/app.dart';

void main() {
  testWidgets('ShopLiteApp launches and displays branding', (WidgetTester tester) async {
    await tester.pumpWidget(const ShopLiteApp());

    // Verify brand title is shown
    expect(find.text('ShopLite'), findsOneWidget);
  });
}
