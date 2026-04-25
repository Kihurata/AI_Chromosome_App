import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/patient.dart';
import '../../../domain/usecases/patient/get_patients.dart';
import '../../../domain/usecases/patient/add_patient.dart';
import '../../../domain/usecases/patient/update_patient.dart';
import '../../../domain/usecases/patient/get_patient_by_id.dart';
import 'patient_state.dart';

@injectable
class PatientCubit extends Cubit<PatientState> {
  final GetPatients getPatientsUsecase;
  final AddPatient addPatientUsecase;
  final UpdatePatient updatePatientUsecase;
  final GetPatientById getPatientByIdUsecase;

  PatientCubit({
    required this.getPatientsUsecase,
    required this.addPatientUsecase,
    required this.updatePatientUsecase,
    required this.getPatientByIdUsecase,
  }) : super(PatientInitial());

  // Hàm lấy danh sách bệnh nhân
  Future<void> fetchPatients() async {
    emit(PatientLoading());
    final result = await getPatientsUsecase();
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patients) => emit(PatientLoaded(patients)),
    );
  }

  // Hàm thêm bệnh nhân
  Future<void> createPatient(Patient patient) async {
    emit(PatientLoading());
    final result = await addPatientUsecase(patient);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (_) => emit(const PatientActionSuccess('Thêm bệnh nhân thành công!')),
    );
  }

  Future<void> updatePatient(Patient patient) async {
    emit(PatientLoading());
    final result = await updatePatientUsecase(patient);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (_) => emit(const PatientActionSuccess('Cập nhật thông tin thành công!')),
    );
  }

  Future<void> getPatientById(String id) async {
    emit(PatientLoading());
    final result = await getPatientByIdUsecase(id);
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientDetailLoaded(patient)),
    );
  }
}
