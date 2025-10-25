import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/sign_in_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/tasks/tasks_cubit.dart';
import 'cubits/groups/groups_cubit.dart';
import 'cubits/friends/friends_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hydrated BLoC storage for state persistence
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  runApp(const SyncTaskApp());
}

class SyncTaskApp extends StatelessWidget {
  const SyncTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<TasksCubit>(
          create: (context) => TasksCubit()..loadSampleData(),
        ),
        BlocProvider<GroupsCubit>(
          create: (context) => GroupsCubit()..loadSampleData(),
        ),
        BlocProvider<FriendsCubit>(
          create: (context) => FriendsCubit()..loadSampleData(),
        ),
      ],
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return MaterialApp(
            title: 'SyncTask',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              primaryColor: const Color(0xFF00D95F),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00D95F),
                secondary: Color(0xFF00D95F),
                surface: Color(0xFF1E1E1E),
                background: Color(0xFF121212),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF121212),
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF00D95F),
                    width: 2,
                  ),
                ),
                hintStyle: const TextStyle(color: Color(0xFF666666)),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D95F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white),
                bodySmall: TextStyle(color: Color(0xFF999999)),
              ),
            ),
            home: authState is AuthAuthenticated
                ? const MainNavigationScreen()
                : const SignInScreen(),
          );
        },
      ),
    );
  }
}
