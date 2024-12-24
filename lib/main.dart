import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:resolvehub/splash_screen.dart';
import 'package:resolvehub/signin_screen.dart';
import 'package:resolvehub/signup_screen.dart';
import 'package:resolvehub/dashboard_screen.dart';
import 'package:resolvehub/profile_screen.dart';
import 'package:resolvehub/problem_posting_screen.dart';
import 'package:resolvehub/problem_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ResolveHub',
      home: SplashScreen(),
      routes: {
        '/signUp': (context) => SignUpScreen(),
        '/signIn': (context) => SignInScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/postProblem': (context) => PostProblemScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      // Use onGenerateRoute for dynamic routes
      onGenerateRoute: (settings) {
        if (settings.name == '/problemDetail') {
          final args = settings.arguments as Map<String, dynamic>?;

          if (args != null && args.containsKey('problemId')) {
            return MaterialPageRoute(
              builder: (context) => ProblemDetailScreen(
                problemId: args['problemId'],
              ),
            );
          }
        }

        // Default fallback for unknown routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
      },
    );
  }
}
