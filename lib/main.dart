import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_theme.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/tasks/tasks_cubit.dart';
import 'cubits/groups/groups_cubit.dart';
import 'cubits/friends/friends_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SyncTaskApp());
}

class SyncTaskApp extends StatelessWidget {
  const SyncTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<TasksCubit>(create: (context) => TasksCubit()),
        BlocProvider<GroupsCubit>(create: (context) => GroupsCubit()),
        BlocProvider<FriendsCubit>(create: (context) => FriendsCubit()),
      ],
      child: MaterialApp(
        title: 'SyncTask',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
