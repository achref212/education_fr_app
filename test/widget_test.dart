import 'package:education_fr_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EducationFrApp());
    expect(find.text('Education FR — Service Layer Ready'), findsOneWidget);
  });
}
