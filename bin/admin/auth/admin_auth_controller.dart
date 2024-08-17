import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../core/utils/extension.dart';
import '../../functions/trimmer.dart';
import 'admin_auth_dto.dart';

class AdminAuthController {
  static const String _adminAuthApi = "/api/v1/admin/auth";
  static const String _adminEmail = "diyorbekflutter@gmail.com";
  static const String _adminPasswordMD5 = "099f1b2af01373d8db534b0c41ff1a2f";

  static void init(Router router){
    _login(router);
  }

  static void _login(Router router) => router.post("$_adminAuthApi/login", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    if(contentType == null || contentType.toLowerCase() != "application/json"){
      return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
    } else if(requestBody.isEmpty) {
      return Response.badRequest(body: "Empty request body".errorStatus);
    }

    Map<String, dynamic> body = Map<String, dynamic>.from(json.decode(requestBody)).trimmer;
    if(!AdminLoginDto.isValid(body)) return Response.badRequest(body: "Body is invalid".errorStatus);
    final AdminLoginDto adminDto = AdminLoginDto.fromJson(body);

    if(_adminEmail != adminDto.email){
      return Response.unauthorized("You are not an admin".errorStatus);
    } else if(_adminPasswordMD5 != adminDto.password.toMd5) {
      return Response.unauthorized("Incorrect password".errorStatus);
    } else {
      return Response.ok(json.encode(adminDto.toJson));
    }
  });
}
