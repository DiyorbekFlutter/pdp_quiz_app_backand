import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/io.dart';

import 'models/connected_user_model.dart';
import 'models/message.dart';
import 'models/purpose_and_data.dart';
import 'purposes.dart';
import 'web_socked_service.dart';
import 'message_status.dart';

class WebSockedHandler {
  static final WebSockedHandler _singleton = WebSockedHandler._internal();
  factory WebSockedHandler() => _singleton;
  WebSockedHandler._internal();

  final List<ConnectedUserModel> connectedUsers = [];

  void handleWebSocket(HttpRequest request) {
    final String? uid = request.uri.queryParameters["uid"];
    if (uid == null || uid.isEmpty) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write("Missing uid parameter")
        ..close();
      return;
    }

    WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
      final channel = IOWebSocketChannel(webSocket);
      connectedUsers.add(ConnectedUserModel(uid: uid, channel: channel));
      print("User successfully connected: $uid");

      if(uid != "admin") {
        sendToAdmin("statusOfUser", {
          "uid": uid,
          "status": "online"
        });
      }

      channel.stream.listen((event) {
        onEvent(PurposeAndData.fromJson(jsonDecode(event)));
      }, onDone: () {
        print("User disconnected: $uid");

        if(uid != "admin") {
          final DateTime time = DateTime.now();
          final String timestamp = "${time.hour}:${time.minute.toString().padLeft(2, "0")}";

          sendToAdmin("statusOfUser", {
            "uid": uid,
            "status": "oxirgi martta: $timestamp"
          });
        }

        connectedUsers.remove(ConnectedUserModel(uid: uid, channel: channel));
      });
    });
  }
  
  void onEvent(PurposeAndData purposeAndData) {
    switch(purposeAndData.purpose){
      case Purposes.message:
        sendMessage(Message.fromJson(purposeAndData.data));
        return;
      case Purposes.messageReceived:
        onMessageReceived(purposeAndData.data["id"]);
        return;
      case Purposes.messageRead:
        onMessageRead(purposeAndData.data["id"], purposeAndData.data["from"], purposeAndData.data["to"]);
        return;
      case Purposes.active:
        active(purposeAndData.data["uid"]);
        return;
      case Purposes.blocked:
        blocked(purposeAndData.data["uid"]);
        return;
      case Purposes.queryUserStatus:
        queryUserStatus(purposeAndData.data["uid"]);
        return;
      case Purposes.getAllMessages:
        getAllMessages(purposeAndData.data["from"], purposeAndData.data["to"]);
      case Purposes.unknown:
        return;
    }
  }



  Future<void> sendMessage(Message message) async {
    message = await WebSockedService.storageMessage(message);
    bool result = sendByUid(message.to, "message", message.toJson);
    if(!result) await WebSockedService.updateStatusMessage(message.id, MessageStatus.notDelivered.name);
  }

  Future<void> onMessageReceived(String id) async {
    await WebSockedService.updateStatusMessage(id, MessageStatus.unread.name);
  }

  Future<void> onMessageRead(String id, String from, String to) async {
    print("Message is read: $id");
    await WebSockedService.updateStatusMessage(id, MessageStatus.read.name);
    await getAllMessages(from, to);
  }

  FutureOr<void> active(String uid) async {
    if(!sendByUid(uid, "active", {})) {
      await WebSockedService.updateUserActive(uid, true);
    }
  }

  FutureOr<void> blocked(String uid) async {
    if(!sendByUid(uid, "blocked", {})) {
      await WebSockedService.updateUserActive(uid, false);
    }
  }

  Future<void> getAllMessages(String from, String to) async {
    print("get all messages: $from");
    final List<Message> messages = await WebSockedService.getAllMessages(from, to);
    sendByUid(from, "allMessages", {"messages": List<Map<String, dynamic>>.from(messages.map((e) => e.toJson).toList())});
  }

  void queryUserStatus(String uid) {
    for(ConnectedUserModel user in connectedUsers) {
      if(uid == user.uid) {
        sendToAdmin("statusOfUser", {
          "uid": uid,
          "status": "online"
        });
        return;
      }
    }

    sendToAdmin("statusOfUser", {
      "uid": uid,
      "status": "offline"
    });
  }

  bool sendToAdmin(String purpose, Map<String, dynamic> data) {
    for(ConnectedUserModel user in connectedUsers) {
      if (user.uid == "admin") {
        user.channel.sink.add(jsonEncode({
          "purpose": purpose,
          "data": data
        }));
        return true;
      }
    }

    return false;
  }

  bool sendByUid(String uid, String purpose, Map<String, dynamic> data) {
    for(ConnectedUserModel user in connectedUsers) {
      if (user.uid == uid) {
        user.channel.sink.add(jsonEncode({
          "purpose": purpose,
          "data": data
        }));
        return true;
      }
    }

    return false;
  }
}
