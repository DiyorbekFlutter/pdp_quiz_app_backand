import 'package:shelf_router/shelf_router.dart';

import '../admin/auth/admin_auth_controller.dart';
import '../admin/questions/questions_controller.dart';
import '../auth/auth_controller.dart';
import '../home/home_controller.dart';
import '../images/images_contrller.dart';
import '../level/level_controller.dart';
import '../profile/profile_controller.dart';
import '../admin/users/users_controller.dart';

class RouterService {
  static final RouterService _singleton = RouterService._internal();
  factory RouterService() => _singleton;
  RouterService._internal();

  final Router _router = Router();

  Router get router {
    /// for admin
    AdminAuthController.init(_router);
    QuestionsController.init(_router);
    UsersController.init(_router);

    /// for users
    AuthController.init(_router);
    HomeController.init(_router);
    ImagesController.init(_router);
    ProfileController.init(_router);
    LevelController.init(_router);
    return _router;
  }
}
