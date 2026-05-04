// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/appointment_remote_datasource.dart' as _i294;
import '../../data/datasources/examination_remote_datasource.dart' as _i851;
import '../../data/datasources/patient_remote_datasource.dart' as _i940;
import '../../data/datasources/specialist_remote_datasource.dart' as _i215;
import '../../data/datasources/test_order_remote_datasource.dart' as _i221;
import '../../data/repositories/appointment_repository_impl.dart' as _i310;
import '../../data/repositories/examination_repository_impl.dart' as _i996;
import '../../data/repositories/image_storage_repository_impl.dart' as _i644;
import '../../data/repositories/patient_repository_impl.dart' as _i308;
import '../../data/repositories/specialist_repository_impl.dart' as _i343;
import '../../data/repositories/test_order_repository_impl.dart' as _i713;
import '../../data/repositories/workspace_repository_impl.dart' as _i964;
import '../../domain/repositories/appointment_repository.dart' as _i53;
import '../../domain/repositories/examination_repository.dart' as _i193;
import '../../domain/repositories/image_storage_repository.dart' as _i970;
import '../../domain/repositories/patient_repository.dart' as _i467;
import '../../domain/repositories/specialist_repository.dart' as _i121;
import '../../domain/repositories/test_order_repository.dart' as _i655;
import '../../domain/repositories/workspace_repository.dart' as _i77;
import '../../domain/usecases/appointment/update_appointment_status.dart'
    as _i379;
import '../../domain/usecases/clinician/create_examination.dart' as _i70;
import '../../domain/usecases/clinician/get_examinations_by_patient.dart'
    as _i314;
import '../../domain/usecases/patient/add_patient.dart' as _i819;
import '../../domain/usecases/patient/check_duplicate_patient.dart' as _i188;
import '../../domain/usecases/patient/get_patient_by_id.dart' as _i1004;
import '../../domain/usecases/patient/get_patients.dart' as _i266;
import '../../domain/usecases/patient/update_patient.dart' as _i485;
import '../../domain/usecases/specialist/get_specialists.dart' as _i760;
import '../../domain/usecases/specialist/trigger_ai_analysis.dart' as _i1057;
import '../../domain/usecases/specialist/update_order_status.dart' as _i814;
import '../../domain/usecases/specialist/upload_image_for_ai_analysis.dart'
    as _i547;
import '../../domain/usecases/specialist/watch_assigned_orders.dart' as _i907;
import '../../domain/usecases/test_order/approve_karyotype_result.dart' as _i63;
import '../../domain/usecases/test_order/assign_order_to_specialist.dart'
    as _i320;
import '../../domain/usecases/test_order/reject_karyotype_result.dart' as _i749;
import '../../domain/usecases/test_order/submit_analysis_result.dart' as _i906;
import '../../domain/usecases/test_order/watch_all_orders.dart' as _i1069;
import '../../logic/bloc/clinician/examination_cubit.dart' as _i41;
import '../../logic/bloc/layout/layout_cubit.dart' as _i556;
import '../../logic/bloc/manager/manager_approval_cubit.dart' as _i429;
import '../../logic/bloc/manager/manager_dashboard_cubit.dart' as _i58;
import '../../logic/bloc/patient/patient_cubit.dart' as _i965;
import '../../logic/bloc/specialist/ai_analysis_cubit.dart' as _i65;
import '../../logic/bloc/specialist/specialist_dashboard_cubit.dart' as _i608;
import '../network/dio_module.dart' as _i614;
import '../network/firebase_module.dart' as _i383;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.auth);
    gh.lazySingleton<_i457.FirebaseStorage>(() => firebaseModule.storage);
    gh.lazySingleton<_i556.LayoutCubit>(() => _i556.LayoutCubit());
    gh.factory<_i215.SpecialistRemoteDataSource>(
      () => _i215.FirebaseSpecialistRemoteDataSource(),
    );
    gh.lazySingleton<_i970.ImageStorageRepository>(
      () => _i644.ImageStorageRepositoryImpl(gh<_i457.FirebaseStorage>()),
    );
    gh.factory<_i221.TestOrderRemoteDataSource>(
      () => _i221.FirebaseTestOrderRemoteDataSource(),
    );
    gh.lazySingleton<_i940.PatientRemoteDataSource>(
      () => _i940.PatientRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i294.AppointmentRemoteDataSource>(
      () => _i294.FirebaseAppointmentRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i77.WorkspaceRepository>(
      () => _i964.WorkspaceRepositoryImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i467.PatientRepository>(
      () => _i308.PatientRepositoryImpl(gh<_i940.PatientRemoteDataSource>()),
    );
    gh.lazySingleton<_i851.ExaminationRemoteDataSource>(
      () =>
          _i851.ExaminationRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i121.SpecialistRepository>(
      () => _i343.SpecialistRepositoryImpl(
        gh<_i215.SpecialistRemoteDataSource>(),
      ),
    );
    gh.factory<_i655.TestOrderRepository>(
      () => _i713.TestOrderRepositoryImpl(
        remoteDataSource: gh<_i221.TestOrderRemoteDataSource>(),
      ),
    );
    gh.factory<_i760.GetSpecialists>(
      () => _i760.GetSpecialists(gh<_i121.SpecialistRepository>()),
    );
    gh.lazySingleton<_i53.AppointmentRepository>(
      () => _i310.AppointmentRepositoryImpl(
        gh<_i294.AppointmentRemoteDataSource>(),
      ),
    );
    gh.factory<_i819.AddPatient>(
      () => _i819.AddPatient(gh<_i467.PatientRepository>()),
    );
    gh.factory<_i188.CheckDuplicatePatient>(
      () => _i188.CheckDuplicatePatient(gh<_i467.PatientRepository>()),
    );
    gh.factory<_i1004.GetPatientById>(
      () => _i1004.GetPatientById(gh<_i467.PatientRepository>()),
    );
    gh.factory<_i266.GetPatients>(
      () => _i266.GetPatients(gh<_i467.PatientRepository>()),
    );
    gh.factory<_i485.UpdatePatient>(
      () => _i485.UpdatePatient(gh<_i467.PatientRepository>()),
    );
    gh.lazySingleton<_i547.UploadImageForAiAnalysis>(
      () => _i547.UploadImageForAiAnalysis(
        gh<_i970.ImageStorageRepository>(),
        gh<_i77.WorkspaceRepository>(),
      ),
    );
    gh.lazySingleton<_i193.ExaminationRepository>(
      () => _i996.ExaminationRepositoryImpl(
        gh<_i851.ExaminationRemoteDataSource>(),
      ),
    );
    gh.factory<_i70.CreateExamination>(
      () => _i70.CreateExamination(gh<_i193.ExaminationRepository>()),
    );
    gh.factory<_i314.GetExaminationsByPatient>(
      () => _i314.GetExaminationsByPatient(gh<_i193.ExaminationRepository>()),
    );
    gh.factory<_i814.UpdateOrderStatus>(
      () => _i814.UpdateOrderStatus(gh<_i655.TestOrderRepository>()),
    );
    gh.factory<_i907.WatchAssignedOrders>(
      () => _i907.WatchAssignedOrders(gh<_i655.TestOrderRepository>()),
    );
    gh.factory<_i63.ApproveKaryotypeResult>(
      () => _i63.ApproveKaryotypeResult(gh<_i655.TestOrderRepository>()),
    );
    gh.factory<_i320.AssignOrderToSpecialist>(
      () => _i320.AssignOrderToSpecialist(gh<_i655.TestOrderRepository>()),
    );
    gh.factory<_i749.RejectKaryotypeResult>(
      () => _i749.RejectKaryotypeResult(gh<_i655.TestOrderRepository>()),
    );
    gh.factory<_i906.SubmitAnalysisResult>(
      () => _i906.SubmitAnalysisResult(gh<_i655.TestOrderRepository>()),
    );
    gh.factory<_i1069.WatchAllOrders>(
      () => _i1069.WatchAllOrders(gh<_i655.TestOrderRepository>()),
    );
    gh.lazySingleton<_i1057.TriggerAiAnalysis>(
      () => _i1057.TriggerAiAnalysis(gh<_i655.TestOrderRepository>()),
    );
    gh.factory<_i379.UpdateAppointmentStatus>(
      () => _i379.UpdateAppointmentStatus(gh<_i53.AppointmentRepository>()),
    );
    gh.factory<_i965.PatientCubit>(
      () => _i965.PatientCubit(
        getPatientsUsecase: gh<_i266.GetPatients>(),
        addPatientUsecase: gh<_i819.AddPatient>(),
        updatePatientUsecase: gh<_i485.UpdatePatient>(),
        getPatientByIdUsecase: gh<_i1004.GetPatientById>(),
        checkDuplicatePatientUsecase: gh<_i188.CheckDuplicatePatient>(),
      ),
    );
    gh.factory<_i429.ManagerApprovalCubit>(
      () => _i429.ManagerApprovalCubit(
        approveKaryotypeResult: gh<_i63.ApproveKaryotypeResult>(),
        rejectKaryotypeResult: gh<_i749.RejectKaryotypeResult>(),
      ),
    );
    gh.factory<_i65.AiAnalysisCubit>(
      () => _i65.AiAnalysisCubit(
        uploadUsecase: gh<_i547.UploadImageForAiAnalysis>(),
        triggerAiUsecase: gh<_i1057.TriggerAiAnalysis>(),
        workspaceRepository: gh<_i77.WorkspaceRepository>(),
      ),
    );
    gh.factory<_i58.ManagerDashboardCubit>(
      () => _i58.ManagerDashboardCubit(
        gh<_i1069.WatchAllOrders>(),
        gh<_i320.AssignOrderToSpecialist>(),
        gh<_i63.ApproveKaryotypeResult>(),
        gh<_i749.RejectKaryotypeResult>(),
        gh<_i760.GetSpecialists>(),
      ),
    );
    gh.factory<_i608.SpecialistDashboardCubit>(
      () => _i608.SpecialistDashboardCubit(
        watchOrdersUsecase: gh<_i907.WatchAssignedOrders>(),
        updateStatusUsecase: gh<_i814.UpdateOrderStatus>(),
      ),
    );
    gh.factory<_i41.ExaminationCubit>(
      () => _i41.ExaminationCubit(
        createExamination: gh<_i70.CreateExamination>(),
        updateAppointmentStatus: gh<_i379.UpdateAppointmentStatus>(),
        getExaminationsByPatient: gh<_i314.GetExaminationsByPatient>(),
      ),
    );
    return this;
  }
}

class _$DioModule extends _i614.DioModule {}

class _$FirebaseModule extends _i383.FirebaseModule {}
