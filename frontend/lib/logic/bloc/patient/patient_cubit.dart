import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/patient_repository.dart';
import 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  final PatientRepository patientRepository;

  PatientCubit({required this.patientRepository}) : super(PatientInitial());

  Future<void> loadPatients() async {
    emit(PatientLoading());
    try {
      final patients = await patientRepository.getAllPatients();
      emit(PatientLoaded(patients: patients));
    } catch (e) {
      emit(PatientError('Không thể tải danh sách bệnh nhân: ${e.toString()}'));
    }
  }

  Future<void> searchPatients(String query) async {
    // Chúng ta có thể chọn search tại local hoặc gọi repo search
    // Ở đây tôi chọn search tại local để nhanh, hoặc bạn có thể thay bằng gọi repo.searchPatients(query)
    try {
      final patients = await patientRepository.searchPatients(query);
      emit(PatientLoaded(patients: patients, searchQuery: query));
    } catch (e) {
      emit(PatientError('Lỗi tìm kiếm: ${e.toString()}'));
    }
  }
}
