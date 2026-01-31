import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'package:nafa_pro/modules/splash/splash_screen.dart';
void main() {
  runApp(const NafaProApp());
}

class NafaProApp extends StatelessWidget {
  const NafaProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nafa Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,

        textSelectionTheme: TextSelectionThemeData(
              cursorColor: Color(0xFF003317),
              selectionColor: Color(0xFF003317),
              selectionHandleColor: Color(0xFF003317), 
            ),
      ),
      getPages: AppPages.routes,   
      home: const SplashScreen(),
    );
  }
}
