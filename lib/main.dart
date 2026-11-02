// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
//
// import 'package:golds_nuts/config/routes_manager/routes.dart';
// import 'package:golds_nuts/config/routes_manager/route_generator.dart';
// import 'package:golds_nuts/core/service_locator.dart';
// import 'package:golds_nuts/core/utils/app_theme.dart';
//
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   setupDependencies();
//
//   runApp(const GoldsNutsApp());
// }
//
// class GoldsNutsApp extends StatelessWidget {
//   const GoldsNutsApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'GoldsNuts',
//       theme: AppTheme.lightTheme,
//
//       initialRoute: Routes.signInRoute,
//       onGenerateRoute: RouteGenerator.getRoute,
//     );
//   }
// }



import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'package:golds_nuts/config/routes_manager/routes.dart';
import 'package:golds_nuts/config/routes_manager/route_generator.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/utils/app_theme.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Authentication Emulator
  await FirebaseAuth.instance.useAuthEmulator(
    '10.0.2.2',
    9099,
  );

  // Cloud Firestore Emulator
  FirebaseFirestore.instance.useFirestoreEmulator(
    '10.0.2.2',
    8080,
  );

  // Cloud Functions Emulator
  FirebaseFunctions.instanceFor(
    region: 'us-central1',
  ).useFunctionsEmulator(
    '10.0.2.2',
    5001,
  );

  setupDependencies();

  runApp(const GoldsNutsApp());
}

class GoldsNutsApp extends StatelessWidget {
  const GoldsNutsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoldsNuts',
      theme: AppTheme.lightTheme,
      initialRoute: Routes.signInRoute,
      onGenerateRoute: RouteGenerator.getRoute,
    );
  }
}
