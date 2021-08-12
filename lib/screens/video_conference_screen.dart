import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_socketio_videocall/controllers/socket_controller.dart';
import 'package:flutter_webrtc_socketio_videocall/controllers/video_conference_controller.dart';
import 'package:get/get.dart';

class VideoConferenceScreen extends GetView<VideoConferenceController> {
  const VideoConferenceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoConferenceController>(
      builder: (_) => Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: buildAppBar(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          onPressed: () {
            Get.find<SocketService>().hangupCall(controller.call!);
            controller.hangUp();
          },
          child: Icon(
            Icons.call_end,
            color: Colors.white,
          ),
        ),
        body: buildVideoRenderers(),
      ),
    );
  }

  Stack buildVideoRenderers() {
    return Stack(
      children: [
        Container(
          width: Get.width,
          height: Get.height,
          child: controller.connectionState ==
                  RTCPeerConnectionState.RTCPeerConnectionStateConnected
              ? RTCVideoView(
                  controller.remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : RTCVideoView(
                  controller.localRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  mirror: true,
                ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            width: 100,
            height: 150,
            child: controller.connectionState ==
                    RTCPeerConnectionState.RTCPeerConnectionStateConnected
                ? RTCVideoView(
                    controller.localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: true,
                  )
                : Expanded(
                    child: Container(
                    color: Colors.black,
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.red)),
                  )),
          ),
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      leadingWidth: 0.0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            child: Text(
              "${controller.user!.name![0]}${controller.user!.surname![0]}",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            backgroundColor: Colors.white,
          ),
          SizedBox(width: 10),
          Text(
            "${controller.user!.name!} ${controller.user!.surname!}",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
      backgroundColor: Colors.red,
    );
  }
}
