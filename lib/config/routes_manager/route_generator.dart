import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/config/routes_manager/routes.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:golds_nuts/features/auth/presentation/screens/login_screen.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_bloc.dart';
import 'package:golds_nuts/features/product/presentation/screens/manager_dashboard_screen.dart';
import 'package:golds_nuts/features/product/presentation/screens/manager_screen.dart';
import 'package:golds_nuts/features/production/presentation/screens/worker/worker_dash_board_screen.dart';

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.signInRoute:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<LoginBloc>(),
            child: const LoginScreen(),
          ),
        );

      case Routes.managerDashboardScreenRoute:
        return MaterialPageRoute(
          builder: (_) => const ManagerDashboardScreen(),
        );

      case Routes.managerScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ProductBloc>(),
            child: const ManagerScreen(),
          ),
        );

      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('No Route Found')),
        body: const Center(child: Text('No Route Found')),
      ),
    );
  }
}
