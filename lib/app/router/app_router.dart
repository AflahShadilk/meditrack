import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../features/medicine/presentation/bloc/medicine_bloc.dart';
import '../../features/medicine/presentation/bloc/medicine_event.dart';
import '../../features/medicine/presentation/pages/add_edit_medicine_page.dart';
import '../../features/medicine/presentation/pages/medicine_list_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider<MedicineBloc>(
        create: (_) => sl<MedicineBloc>()..add(const LoadMedicines()),
        child: const MedicineListPage(),
      ),
      routes: [
        GoRoute(
          path: 'medicine/add',
          builder: (context, state) => BlocProvider.value(
            value: GoRouterState.of(context).extra as MedicineBloc? ??
                sl<MedicineBloc>(),
            child: const AddEditMedicinePage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/design-system',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Design System Preview')),
      ),
    ),
  ],
);
