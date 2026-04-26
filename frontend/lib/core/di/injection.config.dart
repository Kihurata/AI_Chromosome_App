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
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/datasources/patient_remote_datasource.dart' as _i940;
import '../../data/repositories/patient_repository_impl.dart' as _i308;
import '../../domain/repositories/patient_repository.dart' as _i467;
import '../../domain/usecases/patient/add_patient.dart' as _i819;
import '../../domain/usecases/patient/get_patient_by_id.dart' as _i1004;
import '../../domain/usecases/patient/get_patients.dart' as _i266;
import '../../domain/usecases/patient/update_patient.dart' as _i485;
import '../../logic/bloc/patient/patient_cubit.dart' as _i965;
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
    gh.lazySingleton<_i940.PatientRemoteDataSource>(
      () => _i940.PatientRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i467.PatientRepository>(
      () => _i308.PatientRepositoryImpl(gh<_i940.PatientRemoteDataSource>()),
    );
    gh.factory<_i819.AddPatient>(
      () => _i819.AddPatient(gh<_i467.PatientRepository>()),
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
    gh.factory<_i965.PatientCubit>(
      () => _i965.PatientCubit(
        getPatientsUsecase: gh<_i266.GetPatients>(),
        addPatientUsecase: gh<_i819.AddPatient>(),
        updatePatientUsecase: gh<_i485.UpdatePatient>(),
        getPatientByIdUsecase: gh<_i1004.GetPatientById>(),
      ),
    );
    return this;
  }
}

class _$DioModule extends _i614.DioModule {}

class _$FirebaseModule extends _i383.FirebaseModule {}
