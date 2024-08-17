import 'package:web_socket_channel/web_socket_channel.dart';

class ConnectedUserModel {
  final String uid;
  final WebSocketChannel channel;

  const ConnectedUserModel({
    required this.uid,
    required this.channel
  });

  factory ConnectedUserModel.fromJson(Map<String, dynamic> json) => ConnectedUserModel(
    uid: json["uid"],
    channel: json["channel"]
  );




  @override
  int get hashCode => uid.hashCode ^ channel.hashCode;

  @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;
    return other is ConnectedUserModel && other.uid == uid && other.channel == channel;
  }
}
