import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/utils/extension.dart';
import 'profile_change_info_dto.dart';
import 'profile_service.dart';

class ProfileController {
  static const String profileApi = "/api/v1/profile";

  static void init(Router router) {
    profileInfo(router);
    changeProfileInfo(router);
    changeProfileImage(router);
    deleteProfileImage(router);
  }

  static void profileInfo(Router router) => router.get("$profileApi-get-info", (Request request) async {
    final String? uid = request.url.queryParameters["uid"];

    if(uid == null || uid.trim().isEmpty){
      return Response.badRequest(body: "UID parameter is missing".errorStatus);
    } else if(!await ProfileService.checkUserExistsByUid(uid)) {
    return Response.badRequest(body: "Invalid uid".errorStatus);
    }

    try {
      return Response.ok(jsonEncode((await ProfileService.getUserInfoByUid(uid)).toJson));
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void changeProfileInfo(Router router) => router.put("$profileApi-change-info", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String? uid = request.url.queryParameters["uid"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.isEmpty){
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(uid == null || uid.trim().isEmpty){
        return Response.badRequest(body: "UID parameter is missing".errorStatus);
      } else if(!await ProfileService.checkUserExistsByUid(uid)) {
        return Response.badRequest(body: "Invalid uid".errorStatus);
      } else if(!ProfileChangeInfoDto.isValid(jsonDecode(requestBody))){
        return Response.badRequest(body: "Invalid body".errorStatus);
      }

      await ProfileService.changeProfileInfo(uid, ProfileChangeInfoDto.from(jsonDecode(requestBody)));
      return Response.ok(jsonEncode({"status": "done"}));
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void changeProfileImage(Router router) => router.put("$profileApi-change-image", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String? uid = request.url.queryParameters["uid"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.isEmpty){
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(uid == null || uid.trim().isEmpty){
        return Response.badRequest(body: "UID parameter is missing".errorStatus);
      } else if(!await ProfileService.checkUserExistsByUid(uid)) {
        return Response.badRequest(body: "Invalid uid".errorStatus);
      } else if(jsonDecode(requestBody).containsKey("imageBytes") && jsonDecode(requestBody)["imageBytes"].runtimeType == List<int>){
        return Response.badRequest(body: "Invalid body".errorStatus);
      }

      await ProfileService.changeProfileImage(uid, jsonEncode(jsonDecode(requestBody)["imageBytes"]));
      return Response.ok(jsonEncode({"status": "done"}));
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void deleteProfileImage(Router router) => router.delete("$profileApi-delete-image", (Request request) async {
    final String? uid = request.url.queryParameters["uid"];

    try {
      if(uid == null || uid.trim().isEmpty){
        return Response.badRequest(body: "UID parameter is missing".errorStatus);
      } else if(!await ProfileService.checkUserExistsByUid(uid)) {
        return Response.badRequest(body: "Invalid uid".errorStatus);
      }

      await ProfileService.deleteProfileImage(uid);
      return Response.ok(jsonEncode({"status": "done"}));
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });
}
