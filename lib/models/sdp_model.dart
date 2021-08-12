class SdpModel {
  SdpModel({
    this.type,
    this.sdp,
  });

  String? type;
  String? sdp;

  factory SdpModel.fromJson(Map<String, dynamic> json) => SdpModel(
        type: json["type"],
        sdp: json["sdp"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "sdp": sdp,
      };
}
