import 'package:flutter_webrtc/flutter_webrtc.dart' hide navigator;
// ignore: implementation_imports
import 'package:flutter_webrtc/src/native/rtc_peerconnection_factory.dart'
    as RTCNav;
import 'package:flutter_webrtc_socketio_videocall/controllers/socket_controller.dart';
import 'package:flutter_webrtc_socketio_videocall/controllers/user_controller.dart';
import 'package:flutter_webrtc_socketio_videocall/models/call.dart';
import 'package:flutter_webrtc_socketio_videocall/models/candidate.dart';
import 'package:flutter_webrtc_socketio_videocall/models/sdp_model.dart';
import 'package:flutter_webrtc_socketio_videocall/models/user.dart';
import 'package:get/get.dart';

class VideoConferenceController extends GetxController {
  SocketService socketService = Get.find();
  UserController userController = Get.find();
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? peerConnection;
  RTCPeerConnectionState connectionState =
      RTCPeerConnectionState.RTCPeerConnectionStateClosed;
  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;
  Map<String, dynamic> configuration = {};
  bool isOffer = Get.arguments["is_offer"];
  User? user;
  Call? call;

  @override
  void onInit() async {
    if (isOffer) {
      user = Get.arguments["user"];
    } else {
      call = Get.arguments["call"];
      user = call!.from;
    }

    configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    };
    onAddRemoteStream = ((stream) {
      remoteRenderer.srcObject = stream;
      update();
    });

    await initRenderers();
    await openUserMedia();

    if (isOffer) {
      callUser(user!);
    } else {
      handleReceiveCall(call!);
    }
    super.onInit();
  }

  @override
  onClose() {
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.onClose();
  }

  initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    update();
  }

  Future<void> openUserMedia() async {
    var stream = await RTCNav.navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});

    localRenderer.srcObject = stream;
    localStream = stream;

    remoteRenderer.srcObject = await createLocalMediaStream('key');
    update();
  }

  void handleNewIceCandidates(CandidateModel candidateModel) {
    if (peerConnection != null) {
      peerConnection!.addCandidate(
        RTCIceCandidate(
          candidateModel.candidate,
          candidateModel.sdpMid,
          candidateModel.sdpMlineIndex,
        ),
      );
    }
  }

  Future<void> handleAnswer(SdpModel sdpModel) async {
    if (sdpModel.sdp != null) {
      var answer = RTCSessionDescription(
        sdpModel.sdp,
        sdpModel.type,
      );

      print("Someone tried to connect");
      await peerConnection?.setRemoteDescription(answer);
      update();
    }
  }

  Future<void> callUser(User to) async {
    peerConnection = await createPeerConnection(configuration);

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      CandidateModel candidateModel = CandidateModel(
          to: to,
          from: userController.user,
          candidate: candidate.candidate!,
          sdpMid: candidate.sdpMid!,
          sdpMlineIndex: candidate.sdpMlineIndex!);
      socketService.sendIceCandidate(candidateModel);
    };

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    registerPeerConnectionListeners();

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    call = new Call(
        to: to,
        from: userController.user,
        sdp: SdpModel(type: offer.type, sdp: offer.sdp));
    socketService.callSocketUser(call!);
  }

  Future<void> handleReceiveCall(Call call) async {
    peerConnection = await createPeerConnection(configuration);

    peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      print('onIceCandidate: ${candidate.toMap()}');
      CandidateModel candidateModel = CandidateModel(
          to: call.from,
          from: userController.user,
          candidate: candidate.candidate!,
          sdpMid: candidate.sdpMid!,
          sdpMlineIndex: candidate.sdpMlineIndex!);
      socketService.sendIceCandidate(candidateModel);
    };

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream: $track');
        remoteStream?.addTrack(track);
      });
    };

    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    registerPeerConnectionListeners();

    var remoteSdp = RTCSessionDescription(
      call.sdp!.sdp!,
      call.sdp!.type!,
    );

    await peerConnection?.setRemoteDescription(remoteSdp);

    var answer = await peerConnection!.createAnswer();
    print('Created Answer $answer');

    await peerConnection!.setLocalDescription(answer);

    /// Socket send answer sdp
    Call answerCall = new Call(
      to: call.from,
      from: userController.user,
      sdp: SdpModel(type: answer.type, sdp: answer.sdp),
    );
    socketService.makeAnswer(answerCall);
    update();
  }

  Future<void> hangUp({String? snackbarMessage}) async {
    List<MediaStreamTrack> tracks = localRenderer.srcObject!.getTracks();
    tracks.forEach((track) {
      track.stop();
    });

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();

    await localStream!.dispose();
    await remoteStream?.dispose();
    Get.back();
    if (snackbarMessage != null) {
      Get.snackbar("Call Status", snackbarMessage);
    }
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
      connectionState = state;
      update();
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
