import 'package:get_it/get_it.dart';
import '../../features/medicine/data/datasources/medicine_local_data_source.dart';
import '../../features/medicine/data/repositories/medicine_repository_impl.dart';
import '../../features/medicine/domain/repositories/medicine_repository.dart';
import '../../features/medicine/domain/usecases/add_medicine_usecase.dart';
import '../../features/medicine/domain/usecases/delete_medicine_usecase.dart';
import '../../features/medicine/domain/usecases/generate_occurrences_usecase.dart';
import '../../features/medicine/domain/usecases/get_medicines_usecase.dart';
import '../../features/medicine/domain/usecases/pause_medicine_usecase.dart';
import '../../features/medicine/domain/usecases/resume_medicine_usecase.dart';
import '../../features/medicine/domain/usecases/update_medicine_usecase.dart';
import '../../features/medicine/presentation/bloc/medicine_bloc.dart';
import '../../features/reminder/data/datasources/dose_occurrence_local_data_source.dart';
import '../../features/reminder/data/repositories/dose_occurrence_repository_impl.dart';
import '../../features/reminder/domain/repositories/dose_occurrence_repository.dart';

final sl = GetIt.instance;

void setupInjection() {
  // Data Sources
  sl.registerLazySingleton<MedicineLocalDataSource>(
    () => MedicineLocalDataSource(),
  );
  sl.registerLazySingleton<DoseOccurrenceLocalDataSource>(
    () => DoseOccurrenceLocalDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<MedicineRepository>(
    () => MedicineRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<DoseOccurrenceRepository>(
    () => DoseOccurrenceRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GenerateOccurrencesUseCase(sl()));
  sl.registerLazySingleton(() => GetMedicinesUseCase(sl()));
  sl.registerLazySingleton(() => AddMedicineUseCase(sl(), sl()));
  sl.registerLazySingleton(
    () => UpdateMedicineUseCase(sl(), sl(), sl()),
  );
  sl.registerLazySingleton(() => DeleteMedicineUseCase(sl(), sl()));
  sl.registerLazySingleton(() => PauseMedicineUseCase(sl()));
  sl.registerLazySingleton(() => ResumeMedicineUseCase(sl(), sl()));

  // BLoC — registered as factory so each page gets a fresh instance.
  sl.registerFactory<MedicineBloc>(
    () => MedicineBloc(
      getMedicines: sl(),
      addMedicine: sl(),
      updateMedicine: sl(),
      deleteMedicine: sl(),
      pauseMedicine: sl(),
      resumeMedicine: sl(),
    ),
  );
}
