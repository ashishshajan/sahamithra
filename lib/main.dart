import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/global_utils.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/language_provider.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GlobalUtils
  await GlobalUtils.init();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style (translucent, dark icons)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Register GetX controllers
  Get.put(LanguageProvider());
  Get.put(AppProvider());

  runApp(const SahamithraApp());
}

class SahamithraApp extends StatelessWidget {
  const SahamithraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Design frame: iPhone 14 Pro (390 × 844)
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'SAHAMITHRA',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 300),

          // Localization (handled via GetX LanguageProvider)
          locale: const Locale('ml', 'IN'),
          fallbackLocale: const Locale('en', 'US'),

          builder: (context, widget) {
            // Ensure text scaling doesn't break layouts
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  MediaQuery.of(context).textScaleFactor.clamp(0.85, 1.15),
                ),
              ),
              child: widget!,
            );
          },
        );
      },
    );
  }
}
