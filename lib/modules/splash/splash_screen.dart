import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/apiServices.dart';
import '../../routes/app_routes.dart';
import '../appColors/appColors.dart';
import '../loading/loading.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _startAppLogic();
  }

  Future<void> _startAppLogic() async {
    // 1. Petit délai pour l'affichage du logo
    await Future.delayed(const Duration(seconds: 3));

    try {
      // 2. Vérification du Token
      bool isValid = await apiService.isAccessTokenValid();
      
      if (isValid) {
        Get.offAllNamed(Routes.MANAGER_HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- LOGO NAFAGAZ ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      "assets/images/nafagaz_truck_orange.png",
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.local_shipping,
                        color: AppColors.generalColor,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0,
                    ),
                    children: [
                      TextSpan(
                        text: "NAFA",
                        style: TextStyle(color: Color(0xFF003317)),
                      ),
                      TextSpan(
                        text: "GAZ",
                        style: TextStyle(color: Color(0xFFFF5722)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            const Text(
              "L'ÉNERGIE QUI VOUS RAPPROCHE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 60),

            // On appelle directement le widget de chargement ici
            const LoadingWidget(),
          ],
        ),
      ),
    );
  }
}