import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medcore_crm/presentation/pages/receptionist/receptionist_dashboard_page.dart';
import 'package:medcore_crm/presentation/pages/receptionist/patient_list_page.dart';
import 'package:medcore_crm/presentation/pages/receptionist/appointment_calendar_page.dart';
import 'package:medcore_crm/data/repositories/clinical_repository.dart';

class MockClinicalRepository extends Mock implements ClinicalRepository {}
class MockQuerySnapshot extends Mock implements QuerySnapshot {}

void main() {
  late MockClinicalRepository mockRepository;

  setUp(() async {
    await initializeDateFormatting('vi_VN', null);
    mockRepository = MockClinicalRepository();
    
    // Default mocks
    when(() => mockRepository.getTodayAppointments()).thenAnswer((_) => Stream.empty());
    when(() => mockRepository.getAllPatients()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepository.getClinicians()).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ReceptionistDashboardPage(repository: mockRepository),
    );
  }

  testWidgets('ReceptionistDashboardPage renders and navigates via sidebar', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Check summary cards exist on dashboard
    expect(find.text('Lịch hẹn hôm nay'), findsOneWidget);
    expect(find.text('Đang chờ tiếp nhận'), findsOneWidget);

    // Navigate to Bệnh nhân
    await tester.tap(find.text('Bệnh nhân'));
    await tester.pumpAndSettle();

    expect(find.byType(PatientListPage), findsOneWidget);
    expect(find.text('Quản lý hồ sơ và thông tin bệnh nhân'), findsOneWidget);

    // Navigate to Lịch khám
    await tester.tap(find.text('Lịch khám'));
    await tester.pumpAndSettle();

    expect(find.byType(AppointmentCalendarPage), findsOneWidget);
    expect(find.text('Quản lý lịch hẹn và phân công bác sĩ'), findsOneWidget);
  });
}
