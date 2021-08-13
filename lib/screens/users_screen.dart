import 'package:flutter/material.dart';
import 'package:flutter_webrtc_socketio_videocall/controllers/user_controller.dart';
import 'package:flutter_webrtc_socketio_videocall/models/call.dart';
import 'package:flutter_webrtc_socketio_videocall/models/user.dart';
import 'package:flutter_webrtc_socketio_videocall/routes/app_routes.dart';
import 'package:get/get.dart';

class UsersScreen extends GetView<UserController> {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf2f2f2),
      appBar: AppBar(
        leading: Center(
          child: Text(
            'Video Call',
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.start,
          ),
        ),
        leadingWidth: double.infinity,
        backgroundColor: Colors.red,
      ),
      body: GetBuilder<UserController>(
        builder: (_) => controller.users.isEmpty
            ? Center(
                child: Text(
                  "No users found",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade500,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  User user = controller.users[index];
                  return Container(
                    width: Get.width,
                    margin: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 27.5,
                          child: Text(
                            "${user.name![0]}${user.surname![0]}",
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                          backgroundColor: Colors.red,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "${user.name!} ${user.surname!}",
                          style: TextStyle(fontSize: 20),
                        ),
                        Spacer(),
                        IconButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.VIDEO, arguments: {
                                "is_offer": true,
                                "call": new Call(
                                  to: controller.users[index],
                                  from: controller.user,
                                  isVideoCall: false,
                                ),
                              });
                            },
                            icon: Icon(Icons.call)),
                        IconButton(
                            onPressed: () {
                              Get.toNamed(
                                AppRoutes.VIDEO,
                                arguments: {
                                  "is_offer": true,
                                  "call": new Call(
                                    to: controller.users[index],
                                    from: controller.user,
                                    isVideoCall: true,
                                  ),
                                },
                              );
                            },
                            icon: Icon(Icons.video_call)),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
