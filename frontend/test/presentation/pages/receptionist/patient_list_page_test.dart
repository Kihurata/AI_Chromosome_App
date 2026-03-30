import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:medcore_crm/presentation/pages/receptionist/patient_list_page.dart';
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
      home: Scaffold(body: PatientListPage(repository: mockRepository)),
    );
  }

  testWidgets('PatientListPage shows empty state when no patients', (WidgetTester tester) async {
    when(() => mockRepository.getAllPatients()).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start stream

    expect(find.text('Chưa có bệnh nhân nào'), findsOneWidget);
  });

  testWidgets('PatientListPage shows patient list and masks identity card', (WidgetTester tester) async {
    final patients = [
      PatientModel(
        fullName: 'Nguyen Van A',
        patientCode: 'BN-001',
        phone: '090111222',
        identityCard: '123456789012',
        dob: DateTime(1990, 1, 1),
        gender: 'Nam',
      ),
    ];

    when(() => mockRepository.getAllPatients()).thenAnswer((_) => Stream.value(patients));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Start stream

    expect(find.text('Nguyen Van A'), findsOneWidget);
    expect(find.text('BN-001'), findsOneWidget);
    // Masked identity card: 1234********
    expect(find.text('1234********'), findsOneWidget);
  });

  testWidgets('Search query filters the patient list', (WidgetTester tester) async {
     final patients = [
      PatientModel(fullName: 'Alpha', phone: '111', dob: DateTime.now(), gender: 'Nam'),
      PatientModel(fullName: 'Beta', phone: '222', dob: DateTime.now(), gender: 'Nữ'),
    ];

    when(() => mockRepository.getAllPatients()).thenAnswer((_) => Stream.value(patients));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'Alpha');
    await tester.pump();

    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsNothing);
  });
}
