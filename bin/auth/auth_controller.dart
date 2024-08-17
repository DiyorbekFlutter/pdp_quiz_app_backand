import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/utils/extension.dart';
import '../functions/id_generator.dart';
import '../functions/trimmer.dart';
import 'auth_dtos/user_dto_login.dart';
import 'auth_dtos/user_dto_register.dart';
import 'auth_service.dart';

class AuthController {
  static const String authApi = "/api/v1/auth";

  static void init(Router router){
    register(router);
    login(router);
  }

  static void register(Router router) => router.post("$authApi/register", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    if(contentType == null || contentType.toLowerCase() != "application/json"){
      return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
    } else if(requestBody.isEmpty) {
      return Response.badRequest(body: "Empty request body".errorStatus);
    }

    Map<String, dynamic> body = Map<String, dynamic>.from(json.decode(requestBody)).trimmer;
    if(!UserDtoRegister.isValid(body)) return Response.badRequest(body: "Body is invalid".errorStatus);

    final UserDtoRegister userDto = UserDtoRegister.fromJson(body);
    userDto.uid = idGenerator();

    try {
      await AuthService.storage(userDto);
    } catch(e){
      if(e == "Such a user exists"){
        return Response(409, body: "Such a user exists".errorStatus);
      } else {
        return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
      }
    }

    return Response.ok(json.encode(userDto.toJson));
  });

  static void login(Router router) => router.post("$authApi/login", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    if(contentType == null || contentType.toLowerCase() != "application/json"){
      return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
    } else if(requestBody.isEmpty) {
      return Response.badRequest(body: "Empty request body".errorStatus);
    }

    Map<String, dynamic> body = Map<String, dynamic>.from(json.decode(requestBody)).trimmer;
    if(!UserDtoLogin.isValid(body)) return Response.badRequest(body: "Body is invalid".errorStatus);

    final UserDtoLogin userDto = UserDtoLogin.fromJson(body);

    try {
      if(await AuthService.userExists(userDto.email)){
        UserDtoRegister user = await AuthService.getUserInfoByEmail(userDto.email);
        if(userDto.password.toMd5 == user.password){
          return Response.ok(json.encode({
            "uid": user.uid,
            "email": user.email,
            "firstname": user.firstname,
            "lastname": user.lastname,
            "profileImageUrl": user.profileImageUrl,
            "totalScores": user.totalScores.map((e) => e.toJson).toList()
          }));
        } else {
          return Response.unauthorized("Incorrect password".errorStatus);
        }
      } else {
        return Response.notFound("User not found".errorStatus);
      }
    } catch(e){
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });
}
