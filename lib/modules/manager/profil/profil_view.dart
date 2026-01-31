import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profil_controller.dart';
import '../../appColors/appColors.dart';
// import '../../../routes/app_routes.dart'; 
// import '../../wallet/wallet_screen.dart';
// import '../language_screen.dart';
// import '../support_screen.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.generalColor,
        title: const Text("Mon Profil", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit ,color: Colors.white),
            onPressed: () 
            {
              //Get.toNamed(Routes.EDITPROFILE);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(context),
            const SizedBox(height: 30),
            
            // ⚡ SEULEMENT ADRESSES UTILISE LES ROUTES GETX
            _buildMenuItemWithRoute(Icons.location_on, "Mes Adresses"," Routes.ADDRESSLIST"),
            
            // LE RESTE RESTE EN NAVIGATION CLASSIQUE
            // _buildMenuItemWithNav(context, Icons.wallet, "Portefeuille & Parrainage", "const WalletScreen()"),
            // _buildMenuItemWithNav(context, Icons.language, "Langue (Français)", "const LanguageScreen()"),
            // _buildMenuItemWithNav(context, Icons.help_outline, "Aide & Support", "const SupportScreen()"),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Déconnexion", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => controller.confirmLogout(),
            ),
            
            const SizedBox(height: 20),
            Text("Version ${controller.version}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Widget pour la navigation par Route Nommée (GetX)
  Widget _buildMenuItemWithRoute(IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon, color: AppColors.generalColor),//Colors.black54),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => Get.toNamed(routeName),
    );
  }

  // Widget pour la navigation classique (Navigator)
  Widget _buildMenuItemWithNav(BuildContext context, IconData icon, String title, Widget targetPage) {
    return ListTile(
      leading: Icon(icon, color: AppColors.generalColor),//Colors.black54),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50, 
                backgroundColor: AppColors.generalColor, 
                child: const Text("MK", style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold))
              ),
              GestureDetector(
                onTap: () 
                {
                  //Get.toNamed(Routes.EDITPROFILE);
                },
                child: const CircleAvatar(
                  radius: 15, 
                  backgroundColor: Colors.white, 
                  child: Icon(Icons.edit, size: 16, color: Colors.black)
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(controller.userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(controller.userPhone, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}