import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'services/supabase_service.dart';
import 'services/deep_link_service.dart';
import 'providers/auth_provider.dart';
import 'providers/rewards_provider.dart';
import 'providers/staff_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/customer/customer_main_screen.dart';
import 'screens/staff/staff_main_screen.dart';
import 'screens/admin/admin_main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DeepLinkService _deepLinkService;

  @override
  void initState() {
    super.initState();
    _deepLinkService = DeepLinkService();
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'My Real Loyalty App',
            theme: AppTheme.darkTheme,
            routerConfig: _router,
            builder: (context, child) {
              // Initialize deep linking once we have context
              _deepLinkService.initialize(context);
              return child!;
            },
          );
        },
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/customer',
      builder: (context, state) => const CustomerMainScreen(),
    ),
    GoRoute(
      path: '/staff',
      builder: (context, state) => const StaffMainScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminMainScreen(),
    ),
  ],
);