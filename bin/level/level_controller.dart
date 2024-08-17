import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/utils/extension.dart';
import 'level_service.dart';

class LevelController {
  static const String levelApi = "/api/v1/level";

  static void init(Router router) {
    leaderboard(router);
  }

  static void leaderboard(Router router) => router.get("$levelApi-leaderboard", (Request request) async {
    final String? uid = request.url.queryParameters["uid"];
    final String? technologyId = request.url.queryParameters["technologyId"];
    final String? stage = request.url.queryParameters["stage"];

    try {
      if(uid == null || uid.trim().isEmpty){
        return Response.badRequest(body: "UID parameter is missing".errorStatus);
      } else if(stage == null || stage.trim().isEmpty){
        return Response.badRequest(body: "Stage parameter is missing".errorStatus);
      } else if(!["easy", "medium", "hard"].contains(stage)){
        return Response.badRequest(body: "Stage is invalid".errorStatus);
      } else if(technologyId == null || technologyId.trim().isEmpty){
        return Response.badRequest(body: "TechnologyId parameter is missing".errorStatus);
      } else if(!await LevelService.checkTechnologyExists(technologyId)){
        return Response.badRequest(body: "Invalid technologyId".errorStatus);
      } else if(!await LevelService.checkUserExistsByUid(uid)) {
        return Response.badRequest(body: "Invalid uid".errorStatus);
      }

      return Response.ok(jsonEncode((await LevelService.leaderboard(uid, stage, technologyId)).map((e) => e.toJson).toList()));
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });
}
