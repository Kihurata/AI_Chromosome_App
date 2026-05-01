import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medcore_crm/presentation/widgets/shared/containers/app_card.dart';

void main() {
  testWidgets('AppCard nên hiển thị nội dung bên trong', (WidgetTester tester) async {
    // 1. Tạo widget để test
    const testText = 'Hello World';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(
            child: Text(testText),
          ),
        ),
      ),
    );

    // 2. Kiểm tra xem text có xuất hiện không
    expect(find.text(testText), findsOneWidget);
  });

  testWidgets('AppCard nên áp dụng padding chính xác', (WidgetTester tester) async {
    const double paddingValue = 20.0;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(
            padding: EdgeInsets.all(paddingValue),
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    );

    // Kiểm tra container có padding
    final Container container = tester.widget(find.byType(Container));
    expect(container.padding, const EdgeInsets.all(paddingValue));
  });
}
