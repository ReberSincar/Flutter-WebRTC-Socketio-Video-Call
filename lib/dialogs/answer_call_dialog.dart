import 'package:flutter/material.dart';
import 'package:flutter_webrtc_socketio_videocall/services/socket_service.dart';
import 'package:flutter_webrtc_socketio_videocall/models/call.dart';
import 'package:flutter_webrtc_socketio_videocall/routes/app_routes.dart';
import 'package:get/get.dart';

class AnswerCallDialog extends StatelessWidget {
  const AnswerCallDialog({Key? key, required this.call}) : super(key: key);
  final Call call;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
              width: Get.width,
              color: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 75,
                    child: Text(
                      "${call.from!.name![0].toUpperCase()}${call.from!.surname![0].toUpperCase()}",
                      style: TextStyle(color: Colors.red, fontSize: 50),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "${call.from!.name!} ${call.from!.surname!}",
                    style: TextStyle(fontSize: 25, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "${call.from!.username!}",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 20),
                  Text(
                    call.isVideoCall!
                        ? "Incoming Video Call"
                        : "Incoming Audio Call",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(bottom: 50),
                color: Colors.grey.shade900,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.red,
                      child: Icon(
                        Icons.call_end,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Get.find<SocketService>().busyCall(call);
                        Get.back();
                      },
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.call,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.VIDEO, arguments: {
                          "is_offer": false,
                          "call": call,
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
