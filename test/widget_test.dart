import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/app.dart';
import 'package:project360/app/theme/brand_theme.dart';

void main() {
  testWidgets('Brand gallery loads', (tester) async {
    await tester.pumpWidget(
      Project360App(controller: BrandController()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Project360'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('Build an app'), findsOneWidget);
    expect(find.text('Brand studio'), findsOneWidget);
    expect(find.text('Component library'), findsOneWidget);
  });
}
