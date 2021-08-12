import 'package:flutter/material.dart';
import 'package:flutter_webrtc_socketio_videocall/services/socket_service.dart';
import 'package:flutter_webrtc_socketio_videocall/controllers/user_controller.dart';
import 'package:flutter_webrtc_socketio_videocall/routes/app_pages.dart';
import 'package:get/get.dart';

void main() {
  Get.put(UserController());
  Get.put(SocketService());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      getPages: AppPages.pages,
      initialRoute: AppPages.INITIAL_ROUTE,
    );
  }
}
