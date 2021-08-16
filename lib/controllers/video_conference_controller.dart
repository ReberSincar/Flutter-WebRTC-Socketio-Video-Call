import 'package:flutter_webrtc/flutter_webrtc.dart' hide navigator;
// ignore: implementation_imports
import 'package:flutter_webrtc/src/native/rtc_peerconnection_factory.dart'
    as RTCNav;
import 'package:flutter_webrtc_socketio_videocall/services/socket_service.dart';
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
  List<MediaDeviceInfo> mediaDevices = [];

  bool isMuted = false;
  bool isFrontCamera = true;

  bool isOffer = Get.arguments["is_offer"];
  Call? call;
  User? user;

  @override
  void onInit() async {
    call = Get.arguments["call"];
    user = isOffer ? call!.to : call!.from;

    mediaDevices = await Helper.cameras;

    configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302',
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
      callUser(call!);
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
    var stream = await RTCNav.navigator.mediaDevices.getUserMedia(
        {'video': call!.isVideoCall! ? true : false, 'audio': true});

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

  Future createPeerConn(Call call) async {
    peerConnection = await createPeerConnection(configuration);

    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      CandidateModel? candidateModel;
      if (isOffer) {
        candidateModel = CandidateModel(
            to: call.to,
            from: call.from,
            candidate: candidate.candidate!,
            sdpMid: candidate.sdpMid!,
            sdpMlineIndex: candidate.sdpMlineIndex!);
      } else {
        candidateModel = CandidateModel(
            to: call.from,
            from: userController.user,
            candidate: candidate.candidate!,
            sdpMid: candidate.sdpMid!,
            sdpMlineIndex: candidate.sdpMlineIndex!);
      }
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
  }

  Future<void> callUser(Call call) async {
    await createPeerConn(call);

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    call.sdp = SdpModel(type: offer.type, sdp: offer.sdp);
    socketService.callSocketUser(call);
  }

  Future<void> handleReceiveCall(Call call) async {
    await createPeerConn(call);

    var remoteSdp = RTCSessionDescription(
      call.sdp!.sdp!,
      call.sdp!.type!,
    );

    await peerConnection?.setRemoteDescription(remoteSdp);

    RTCSessionDescription answer = await peerConnection!.createAnswer();
    print('Created Answer $answer');

    await peerConnection!.setLocalDescription(answer);

    /// Socket send answer sdp
    Call answerCall = new Call(
      to: call.from,
      from: userController.user,
      sdp: SdpModel(type: answer.type, sdp: answer.sdp),
      isVideoCall: call.isVideoCall,
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

  void switchCamera() async {
    if (localStream != null) {
      if (mediaDevices.length > 1) {
        MediaStreamTrack value = localStream!.getVideoTracks()[0];
        await Helper.switchCamera(
          value,
          // isFrontCamera
          //     ? mediaDevices.first.deviceId
          //     : mediaDevices[1].deviceId,
        );
        isFrontCamera = !isFrontCamera;
        update();
      }
    }
  }

  void muteMicrophone() async {
    if (localStream != null) {
      Helper.setMicrophoneMute(!isMuted, localStream!.getAudioTracks()[0]);
      isMuted = !isMuted;
      update();
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
