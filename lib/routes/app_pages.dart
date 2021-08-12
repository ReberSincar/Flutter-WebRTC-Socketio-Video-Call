import 'package:flutter_webrtc_socketio_videocall/bindings/video_binding.dart';
import 'package:flutter_webrtc_socketio_videocall/screens/connect_screent.dart';
import 'package:flutter_webrtc_socketio_videocall/screens/users_screen.dart';
import 'package:flutter_webrtc_socketio_videocall/screens/video_conference_screen.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL_ROUTE = AppRoutes.CONNECT;
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.CONNECT,
      page: () => ConnectScreen(),
    ),
    GetPage(
      name: AppRoutes.USERS,
      page: () => UsersScreen(),
    ),
    GetPage(
      name: AppRoutes.VIDEO,
      page: () => VideoConferenceScreen(),
      binding: VideoBinding(),
    ),
  ];
}
