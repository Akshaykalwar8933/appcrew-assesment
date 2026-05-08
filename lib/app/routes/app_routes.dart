import 'package:get/get.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/signup_view.dart';
import '../../modules/auth/views/splash_view.dart';
import '../../modules/notes/controllers/notes_controller.dart';
import '../../modules/notes/views/home_view.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';

  static final routes = [

    GetPage(name: splash, page: () => const SplashView()),

    GetPage(name: login, page: () => LoginView()),

    GetPage(name: signup, page: () => SignupView()),

    GetPage(name: home, page: () => HomeView(), binding: HomeBinding()),
  ];
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotesController>(() => NotesController());
  }
}
