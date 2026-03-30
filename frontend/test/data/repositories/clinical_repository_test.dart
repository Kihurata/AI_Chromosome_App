import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:medcore_crm/data/repositories/clinical_repository.dart';
import 'package:medcore_crm/data/models/patient_model.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ClinicalRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ClinicalRepository(firestore: firestore);
  });

  group('ClinicalRepository - Patient CRUD', () {
    test('createPatient should add patient to Firestore and return ID with generated code', () async {
      final patient = PatientModel(
        fullName: 'Nguyen Van A',
        dob: DateTime(1990, 1, 1),
        gender: 'Nam',
        phone: '0901234567',
        identityCard: '123456789',
      );

      final id = await repository.createPatient(patient);
      
      expect(id, isNotEmpty);
      
      final doc = await firestore.collection('patients').doc(id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['full_name'], 'Nguyen Van A');
      expect(doc.data()?['patient_code'], startsWith('BN-'));
    });

    test('checkDuplicatePatient should return patient if identity_card matches', () async {
      final existingPatient = PatientModel(
        fullName: 'Duplicate Patient',
        dob: DateTime(1985, 5, 5),
        gender: 'Nữ',
        phone: '0988888888',
        identityCard: '987654321',
      );
      
      await firestore.collection('patients').add(existingPatient.toFirestore());

      final result = await repository.checkDuplicatePatient(identityCard: '987654321');
      
      expect(result, isNotNull);
      expect(result?.fullName, 'Duplicate Patient');
    });

    test('checkDuplicatePatient should return patient if phone matches', () async {
       final existingPatient = PatientModel(
        fullName: 'Phone Duplicate',
        dob: DateTime(1980, 2, 2),
        gender: 'Nam',
        phone: '0977777777',
      );
      
      await firestore.collection('patients').add(existingPatient.toFirestore());

      final result = await repository.checkDuplicatePatient(phone: '0977777777');
      
      expect(result, isNotNull);
      expect(result?.fullName, 'Phone Duplicate');
    });

    test('checkDuplicatePatient should return null if no duplicates found', () async {
      final result = await repository.checkDuplicatePatient(
        identityCard: 'non_existent',
        phone: '0000000000',
      );
      
      expect(result, isNull);
    });

    test('searchPatients should return matched patients by multiple fields', () async {
      final patients = [
        PatientModel(fullName: 'John Doe', phone: '111', dob: DateTime.now(), gender: 'Nam'),
        PatientModel(fullName: 'Jane Smith', phone: '222', dob: DateTime.now(), gender: 'Nữ', identityCard: 'ID999'),
        PatientModel(fullName: 'Bob Brown', phone: '333', dob: DateTime.now(), gender: 'Nam', patientCode: 'BN-BOB'),
      ];

      for (var p in patients) {
        await firestore.collection('patients').add(p.toFirestore());
      }

      // Search by name
      final resultName = await repository.searchPatients('John');
      expect(resultName.length, 1);
      expect(resultName.first.fullName, 'John Doe');

      // Search by phone
      final resultPhone = await repository.searchPatients('222');
      expect(resultPhone.length, 1);
      expect(resultPhone.first.fullName, 'Jane Smith');

      // Search by ID card
      final resultId = await repository.searchPatients('ID999');
      expect(resultId.length, 1);
      expect(resultId.first.fullName, 'Jane Smith');

      // Search by patient code
      final resultCode = await repository.searchPatients('BN-BOB');
      expect(resultCode.length, 1);
      expect(resultCode.first.fullName, 'Bob Brown');
    });
  });
}
