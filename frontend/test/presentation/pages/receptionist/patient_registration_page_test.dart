import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medcore_crm/presentation/pages/receptionist/patient_registration_page.dart';
import 'package:medcore_crm/data/repositories/clinical_repository.dart';
import 'package:medcore_crm/data/models/patient_model.dart';

class MockClinicalRepository extends Mock implements ClinicalRepository {}

void main() {
  late MockClinicalRepository mockRepository;

  setUp(() {
    mockRepository = MockClinicalRepository();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: PatientRegistrationPage(repository: mockRepository),
    );
  }

  testWidgets('PatientRegistrationPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Tiếp nhận bệnh nhân tại quầy'), findsOneWidget);
    expect(find.text('1. Thông tin định danh'), findsOneWidget);
    expect(find.text('2. Địa chỉ & Liên lạc'), findsOneWidget);
    expect(find.text('Họ và tên'), findsOneWidget);
  });

  testWidgets('Validation errors show when fields are empty on submit', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Scroll to find submit button if necessary
    final submitButton = find.text('Lưu hồ sơ');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('Vui lòng nhập Họ và tên'), findsOneWidget);
    expect(find.text('Vui lòng nhập Số CCCD / Hộ chiếu'), findsOneWidget);
    expect(find.text('Vui lòng nhập Số điện thoại'), findsOneWidget);
    expect(find.text('Vui lòng chọn ngày sinh'), findsOneWidget);
  });

  testWidgets('Duplicate warning shows when repository returns an existing patient', (WidgetTester tester) async {
    final existingPatient = PatientModel(
      fullName: 'John Existing',
      dob: DateTime.now(),
      gender: 'Nam',
      phone: '123456789',
      patientCode: 'BN-12345',
    );

    // Mock checkDuplicatePatient to return a patient
    when(() => mockRepository.checkDuplicatePatient(
          identityCard: any(named: 'identityCard'),
          phone: any(named: 'phone'),
        )).thenAnswer((_) async => existingPatient);

    await tester.pumpWidget(createWidgetUnderTest());

    // Enter some text into identity card field
    await tester.enterText(find.byType(TextField).at(1), '001122334455');
    await tester.pumpAndSettle(); // Wait for debounce or checkDuplicate

    expect(find.textContaining('Bệnh nhân "John Existing" đã tồn tại'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber), findsNothing); // Uses Lucide Icons in real code, but check text is safer
  });
}
