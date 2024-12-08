import 'package:SmartHomz/routes/routes.dart';
import 'package:SmartHomz/screens/login.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../screens/homescreen.dart';

class AppRoutes{
  static final pages  = [
  GetPage(name: Routes.home, page: () => const HomeScreen()),
  GetPage(name: Routes.login, page: () => const LoginScreen()),

 ];
}