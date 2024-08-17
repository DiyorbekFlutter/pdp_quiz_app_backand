import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../core/utils/extension.dart';
import '../../admin/users/models/update_user_info_dto.dart';
import 'users_service.dart';

class UsersController {
  static const String _usersApi = "/api/v1/admin/users";

  static void init(Router router){
    getAllUsers(router);
    getUserInfo(router);
    updateUserInfo(router);
  }

  static void getAllUsers(Router router) => router.get("$_usersApi-get-all-users", (Request request) async {
    try {
      final List<Map<String, dynamic>> users = await UsersService.getAllUsers();
      return Response.ok(jsonEncode(users));
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void getUserInfo(Router router) => router.get("$_usersApi-get-user-info", (Request request) async {
    final String? uid = request.url.queryParameters["uid"];

    if(uid == null || uid.trim().isEmpty){
      return Response.badRequest(body: "UID parameter is missing".errorStatus);
    }

    try {
      final Map<String, dynamic> result = await UsersService.getUserInfo(uid);
      return Response.ok(jsonEncode(result));
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void updateUserInfo(Router router) => router.put("$_usersApi-update-user-info", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.isEmpty){
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(!UpdateUserInfoDto.isValid(jsonDecode(requestBody))){
        return Response.badRequest(body: "Invalid body".errorStatus);
      }

      await UsersService.updateUserInfo(UpdateUserInfoDto.fromJson(jsonDecode(requestBody)));
      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });
}
