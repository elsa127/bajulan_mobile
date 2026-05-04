import 'package:flutter_test/flutter_test.dart';
import 'package:bajulan_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BajulanApp());
    await tester.pumpAndSettle();
  });
}
