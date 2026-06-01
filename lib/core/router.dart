import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/add_habit_step1_screen.dart';
import '../screens/add_habit_step2_screen.dart';
import '../screens/edit_habit_screen.dart';
import '../screens/habit_detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/onboarding/onboarding_step1_screen.dart';
import '../screens/onboarding/onboarding_step2_screen.dart';
import '../screens/onboarding/onboarding_step3_screen.dart';
import '../screens/onboarding/onboarding_step4_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/stats_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool('onboarding_done') ?? false;
      final loc = state.matchedLocation;

      if (!done && !loc.startsWith('/onboarding')) {
        return '/onboarding/step1';
      }
      if (done && loc.startsWith('/onboarding')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding/step1',
        builder: (context, state) => const OnboardingStep1Screen(),
      ),
      GoRoute(
        path: '/onboarding/step2',
        builder: (context, state) => const OnboardingStep2Screen(),
      ),
      GoRoute(
        path: '/onboarding/step3',
        builder: (context, state) => OnboardingStep3Screen(extra: state.extra),
      ),
      GoRoute(
        path: '/onboarding/step4',
        builder: (context, state) => OnboardingStep4Screen(extra: state.extra),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/habit/add/step1',
        builder: (context, state) => const AddHabitStep1Screen(),
      ),
      GoRoute(
        path: '/habit/add/step2',
        builder: (context, state) => const AddHabitStep2Screen(),
      ),
      GoRoute(
        path: '/habit/:id',
        builder: (context, state) => HabitDetailScreen(
          habitId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/habit/:id/edit',
        builder: (context, state) => EditHabitScreen(
          habitId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
