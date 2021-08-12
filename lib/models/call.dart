import 'package:flutter_webrtc_socketio_videocall/models/sdp_model.dart';
import 'package:flutter_webrtc_socketio_videocall/models/user.dart';

class Call {
  Call({
    this.to,
    this.from,
    this.sdp,
  });

  User? to;
  User? from;
  SdpModel? sdp;

  factory Call.fromJson(Map<String, dynamic> json) => Call(
        to: User.fromJson(json["to"]),
        from: User.fromJson(json["from"]),
        sdp: SdpModel.fromJson(json["sdp"]),
      );

  Map<String, dynamic> toJson() => {
        "to": to!.toJson(),
        "from": from!.toJson(),
        "sdp": sdp!.toJson(),
      };
}
