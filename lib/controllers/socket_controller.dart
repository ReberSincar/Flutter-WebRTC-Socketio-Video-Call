import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_socketio_videocall/controllers/user_controller.dart';
import 'package:flutter_webrtc_socketio_videocall/controllers/video_conference_controller.dart';
import 'package:flutter_webrtc_socketio_videocall/dialogs/answer_call_dialog.dart';
import 'package:flutter_webrtc_socketio_videocall/models/call.dart';
import 'package:flutter_webrtc_socketio_videocall/models/candidate.dart';
import 'package:flutter_webrtc_socketio_videocall/routes/app_routes.dart';
import 'package:get/get.dart' as GET;
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart';

typedef void StreamStateCallback(MediaStream stream);

class SocketService extends GET.GetxController {
  Socket? socket;
  UserController userController = GET.Get.find();

  handleSocket() {
    socket = io("Your server address here",
        OptionBuilder().setTransports(['websocket']).build());

    socket!.onConnect((_) {
      printInfo(info: 'SOCKETT connected');
      socket!.emit('connectUser', userController.user.toJson());
    });

    socket!.on('username-already-exist', (data) {
      socket!.disconnect();
      GET.Get.snackbar("Error", "Username already exist");
    });

    socket!.on('user-registered', (data) {
      GET.Get.offNamed(AppRoutes.USERS);
    });

    socket!.onDisconnect((_) {
      printInfo(info: 'SOCKETT disconnect');
    });

    // Listen for online users
    socket!.on('users', (data) {
      printInfo(info: 'SOCKETT Users $data');
      userController.addUsers(data);
    });

    // Handle Receive Call
    socket!.on('call-made', (data) async {
      printInfo(info: 'SOCKETT CALL MADE $data');
      Call call = Call.fromJson(data);
      if (call.sdp != null) {
        Get.dialog(AnswerCallDialog(call: call));
      }
    });

    // Handle Answer
    socket!.on('answer-made', (data) async {
      printInfo(info: 'SOCKETT ANSWER MADE $data');
      if (Get.isRegistered<VideoConferenceController>()) {
        Get.find<VideoConferenceController>()
            .handleAnswer(Call.fromJson(data).sdp!);
      }
    });

    // Handle Ice Candidate
    socket!.on('ice-candidate', (data) async {
      printInfo(info: 'SOCKETT Ice candidate $data');
      if (Get.isRegistered<VideoConferenceController>()) {
        Get.find<VideoConferenceController>()
            .handleNewIceCandidates(CandidateModel.fromJson(data));
      }
    });

    // Listen for hangup
    socket!.on('hangup', (data) async {
      printInfo(info: 'SOCKETT Hangup $data');
      if (Get.isRegistered<VideoConferenceController>()) {
        Get.find<VideoConferenceController>()
            .hangUp(snackbarMessage: "User closed call");
      }
    });

    // Listen for busy
    socket!.on('busy', (data) async {
      printInfo(info: 'SOCKETT busy $data');
      if (Get.isRegistered<VideoConferenceController>()) {
        Get.find<VideoConferenceController>()
            .hangUp(snackbarMessage: "User is busy");
      }
    });
  }

  // Call a user
  callSocketUser(Call call) {
    socket!.emit('call-user', call.toJson());
  }

  // Answer call
  makeAnswer(Call call) {
    socket!.emit('make-answer', call.toJson());
  }

  // Send Ice Candidate
  sendIceCandidate(CandidateModel candidate) {
    socket!.emit('ice-candidate', candidate.toJson());
  }

  // Close call
  hangupCall(Call call) {
    socket!.emit('hangup', call.toJson());
  }

  // Get busy
  busyCall(Call call) {
    socket!.emit('busy', call.toJson());
  }
}
