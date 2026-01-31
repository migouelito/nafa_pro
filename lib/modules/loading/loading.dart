import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../appColors/appColors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Widget de chargement avec DotView (fond transparent)
class LoadingWidget extends StatelessWidget {
  final String? text;

  const LoadingWidget({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ===== DOT VIEW TRANSPARENT =====
            SpinKitThreeBounce(
              color: AppColors.generalColor,
              size: 30,
            ),

            // Texte optionnel
            if (text != null) ...[
              const SizedBox(height: 14),
              Text(
                text!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ================= MODAL LOADING =================
class LoadingModal {
  static bool _isShowing = false;

  static void show({String? text}) {
    if (_isShowing) return;

    Get.dialog(
      LoadingWidget(text: text),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4), // overlay sombre
    );

    _isShowing = true;
  }

  static void hide() {
    if (_isShowing) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      _isShowing = false;
    }
  }
}
