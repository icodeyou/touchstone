import 'package:go_router/go_router.dart';
import 'package:touchstone/core/app/routing/paths.dart';
import 'package:touchstone/ui/home/view/home_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      // If a page is invalid, go_router will suggest to go to '/'
      path: '/',
      redirect: (context, state) => Paths.home.location,
    ),
    GoRoute(
      path: Paths.home.location,
      name: Paths.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
