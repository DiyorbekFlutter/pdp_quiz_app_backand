class Message {
  String id;
  String status;
  final String from;
  final String to;
  final String content;
  final String timestamp;

  Message({
    required this.id,
    required this.status,
    required this.from,
    required this.to,
    required this.content,
    required this.timestamp
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"] ?? "",
    status: json["status"] ?? "",
    from: json["from"],
    to: json["to"],
    content: json["content"],
    timestamp: json["timestamp"]
  );

  Map<String, String> get toJson => {
    "id": id,
    "from": from,
    "to": to,
    "content": content,
    "status": status,
    "timestamp": timestamp
  };

  Message copyWith({
    String? id,
    String? status,
    String? from,
    String? to,
    String? content,
    String? timestamp,
  }) => Message(
    id: id ?? this.id,
    status: status ?? this.status,
    from: from ?? this.from,
    to: to ?? this.to,
    content: content ?? this.content,
    timestamp: timestamp ?? this.timestamp
  );
}
