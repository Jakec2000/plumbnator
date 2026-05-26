import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation/navigation_shell.dart';
import '../views/hubs/operations_hub_view.dart';
import '../views/hubs/sizers_hub_view.dart';
import '../views/hubs/field_docs_hub_view.dart';
import '../views/hubs/compliance_hub_view.dart';
import '../views/error/global_error_view.dart';

// Global navigator key to access navigator context if needed
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// The declarative App Router configured with GoRouter
final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/operations',
  errorBuilder: (context, state) => GlobalErrorView(
    errorMessage: state.error?.toString() ?? 'Unknown Routing Exception',
  ),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/operations',
              builder: (context, state) => const OperationsHubView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sizers',
              builder: (context, state) => const SizersHubView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/field-docs',
              builder: (context, state) => const FieldDocsHubView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/compliance',
              builder: (context, state) => const ComplianceHubView(),
            ),
          ],
        ),
      ],
    ),
  ],
);
