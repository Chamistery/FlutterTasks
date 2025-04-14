import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'di/di.dart';
import 'screens/home_screen.dart';
import 'presentation/bloc/liked_cats_cubit.dart';

void main() {
  setupDI();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LikedCatsCubit>(
      create: (_) => getIt<LikedCatsCubit>(),
      child: MaterialApp(
        title: 'Cat Tinder',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
