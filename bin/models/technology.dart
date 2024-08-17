class Technology {
  String id;
  String imageUrl;
  String title;

  Technology({
    required this.id,
    required this.imageUrl,
    required this.title
  });

  factory Technology.fromJson(Map<String, dynamic> json) => Technology(
    id: json["id"] as String,
    imageUrl: json["imageUrl"] as String,
    title: json["title"] as String
  );

  Map<String, dynamic> get toJson => {
    "id": id,
    "imageUrl": imageUrl,
    "title": title
  };
}
