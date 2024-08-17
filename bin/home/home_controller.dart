import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../auth/auth_dtos/user_dto_register.dart';
import '../core/utils/extension.dart';
import 'home_service.dart';
import '../models/modules.dart';
import 'models/scores_system_model.dart';
import 'models/technologies.dart';

class HomeController {
  static const String homeApi = "/api/v1/home";

  static void init(Router router) {
    technologies(router);
    modules(router);
    addBall(router);
  }

  static void technologies(Router router) => router.get("$homeApi-technologies", (Request request) async {
    final String? uid = request.url.queryParameters['uid'];

    if(uid == null || uid.trim().isEmpty){
      return Response.badRequest(body: "UID parameter is missing".errorStatus);
    } else if(!await HomeService.checkUserExistsByUid(uid)) {
      return Response.badRequest(body: "Invalid uid".errorStatus);
    }

    try {
      UserDtoRegister user = await HomeService.getUserInfoByUid(uid);
      return Response.ok(json.encode(
        Technologies(
          userName: user.firstname,
          userProfileImageUrl: user.profileImageUrl,
          technologies: await HomeService.getAllTechnologies()
        ).toJson
      ));
    } catch(e) {
      print(e);
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void modules(Router router) => router.get("$homeApi-modules", (Request request) async {
    final String? technologyId = request.url.queryParameters["technologyId"];
    final String? stage = request.url.queryParameters['stage'];

    if(technologyId ==  null || technologyId.trim().isEmpty){
      return Response.badRequest(body: "Technology Id parameter is missing".errorStatus);
    } else if(stage ==  null || stage.trim().isEmpty){
      return Response.badRequest(body: "Stage parameter is missing".errorStatus);
    }

    late final (String, String) technologyInfo;
    late final Modules modules;

    try {
      technologyInfo = await HomeService.getTechnologyInfoById(technologyId);
      modules = await HomeService.getModules(technologyId, stage);
    } catch(e){
      if(e == "Bad state: No element"){
        return Response.notFound("No element".errorStatus);
      } else {
        return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
      }
    }

    return Response.ok(jsonEncode({
      "title": technologyInfo.$1,
      "stage": stage,
      "imageUrl": technologyInfo.$2,
      "modules": modules.toJson
    }));
  });

  static void addBall(Router router) => router.put("$homeApi-add-ball", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String? uid = request.url.queryParameters["uid"];
    final String requestBody = await request.readAsString();

    if(contentType == null || contentType.toLowerCase() != "application/json"){
      return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
    } else if(requestBody.isEmpty){
      return Response.badRequest(body: "Empty request body".errorStatus);
    } else if(uid == null || uid.trim().isEmpty){
      return Response.badRequest(body: "UID parameter is missing".errorStatus);
    } else if(!await HomeService.checkUserExistsByUid(uid)) {
      return Response.badRequest(body: "Invalid uid".errorStatus);
    } else if(!ScoresSystemModel.isValid(jsonDecode(requestBody))){
      return Response.badRequest(body: "Invalid body".errorStatus);
    }

    try {
      await HomeService.addBall(uid, ScoresSystemModel.fromJson(jsonDecode(requestBody)));
      return Response.ok(jsonEncode({"message": "Ball is successfully added"}));
    } catch(e){
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });
}
