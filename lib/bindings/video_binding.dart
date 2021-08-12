import 'package:flutter_webrtc_socketio_videocall/controllers/video_conference_controller.dart';
import 'package:get/get.dart';

class VideoBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(VideoConferenceController());
  }
}
