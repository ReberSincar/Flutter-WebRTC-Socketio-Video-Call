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
      child: SimpleDialog(
        contentPadding: EdgeInsets.all(10),
        backgroundColor: Colors.black45,
        children: [
          Container(
            color: Colors.black45,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        child: Text(
                          "${call.from!.name![0].toUpperCase()}${call.from!.surname![0].toUpperCase()}",
                          style: TextStyle(color: Colors.red, fontSize: 30),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${call.from!.name!} ${call.from!.surname!}",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${call.from!.username!}",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Calling...",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
