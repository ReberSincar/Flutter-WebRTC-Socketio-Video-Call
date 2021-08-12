import 'package:flutter/material.dart';
import 'package:flutter_webrtc_socketio_videocall/services/socket_service.dart';
import 'package:flutter_webrtc_socketio_videocall/models/user.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  List users = [];
  User user = new User();
  GlobalKey<FormState> connectFormKey = new GlobalKey<FormState>();

  connectToSocket() {
    if (connectFormKey.currentState!.validate()) {
      Get.find<SocketService>().handleSocket();
    }
  }

  addUsers(data) {
    users.clear();
    for (var item in data) {
      User newUser = User.fromJson(item);
      if (newUser.username != user.username) {
        users.add(User.fromJson(item));
      }
      // users.add(User.fromJson(item));
    }
    update();
  }
}
