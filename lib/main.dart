import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'app/core/theme/app_theme.dart';
import 'app/data/local/preference/app_preferences.dart';
import 'app/data/local/db/app_database.dart';
import 'app/di/service_locator.dart';
import 'app/modules/auth/service/auth_manager.dart';
import 'app/modules/dashboard/bloc/dashboard_bloc.dart';
import 'app/modules/dashboard/bloc/dashboard_event.dart';
import 'app/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  await configureDependencies();
  await AppDatabase.init();

  final token = AppPreferences.getString('auth_token');
  if (token != null) {
    final authManager = GetIt.instance<AuthManager>();
    // Refresh the token first so any stale stored token is replaced before
    // we attempt authenticated calls (e.g. fetchUserProfile).
    await authManager.refreshToken();
    authManager.startTokenRefreshTimer();
    authManager.fetchUserProfile();
  }

  runApp(const AnexeeApp());
}

class AnexeeApp extends StatelessWidget {
  const AnexeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (_) => GetIt.instance<DashboardBloc>()..add(const LoadProfiles()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Anexee — Analytical Excellence',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
