import 'package:flutter_webrtc_socketio_videocall/models/user.dart';

class CandidateModel {
  CandidateModel({
    this.to,
    this.from,
    this.candidate,
    this.sdpMid,
    this.sdpMlineIndex,
  });

  User? to;
  User? from;
  String? candidate;
  String? sdpMid;
  int? sdpMlineIndex;

  factory CandidateModel.fromJson(Map<String, dynamic> json) => CandidateModel(
        to: User.fromJson(json["to"]),
        from: User.fromJson(json["from"]),
        candidate: json["candidate"],
        sdpMid: json["sdpMid"],
        sdpMlineIndex: json["sdpMlineIndex"],
      );

  Map<String, dynamic> toJson() => {
        "to": to!.toJson(),
        "from": from!.toJson(),
        "candidate": candidate,
        "sdpMid": sdpMid,
        "sdpMlineIndex": sdpMlineIndex,
      };
}
