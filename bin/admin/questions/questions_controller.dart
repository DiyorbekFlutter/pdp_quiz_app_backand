import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../core/utils/extension.dart';
import '../../admin/questions/dtos/technology_dto.dart';
import '../../admin/questions/dtos/module_dto.dart';
import '../../admin/questions/dtos/department_dto.dart';
import '../../admin/questions/dtos/department_update_dto.dart';
import '../../admin/questions/dtos/question_dto.dart';
import '../../admin/questions/dtos/question_update_dto.dart';
import '../../models/modules.dart';
import '../../home/home_service.dart';
import 'questions_service.dart';

class QuestionsController {
  static const String _questionsApi = "/api/v1/admin/questions";

  static void init(Router router){
    technologies(router);
    addTechnology(router);
    updateTechnology(router);
    deleteTechnology(router);

    modules(router);
    addModule(router);
    deleteModule(router);

    addDepartment(router);
    updateDepartment(router);
    deleteDepartment(router);

    questions(router);
    addQuestion(router);
    updateQuestion(router);
    deleteQuestion(router);
  }

  /// technology ---------------------------------------------------------------------------------------

  static void technologies(Router router) => router.get("$_questionsApi-technologies", (Request request) async {
    try {
      return Response.ok(jsonEncode(await QuestionsService.getAllTechnologies()));
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void addTechnology(Router router) => router.post("$_questionsApi-add-technology", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.isEmpty) {
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(!TechnologyDto.isValid(jsonDecode(requestBody))){
        return Response.badRequest(body: "Invalid body".errorStatus);
      }

      final TechnologyDto dto = TechnologyDto.fromJson(jsonDecode(requestBody));
      await QuestionsService.storageTechnology(dto);

      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void updateTechnology(Router router) => router.put("$_questionsApi-update-technology", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.trim().isEmpty) {
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(!TechnologyDto.isValidForUpdate(jsonDecode(requestBody))){
        return Response.badRequest(body: "Body is invalid");
      }

      await QuestionsService.updateTechnology(jsonDecode(requestBody));
      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void deleteTechnology(Router router) => router.delete("$_questionsApi-delete-technology", (Request request) async {
    final String? technologyId = request.url.queryParameters["technologyId"];

    if(technologyId ==  null || technologyId.trim().isEmpty){
      return Response.badRequest(body: "Technology Id parameter is missing".errorStatus);
    }

    try {
      await QuestionsService.deleteTechnology(technologyId);
      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });



  /// module -------------------------------------------------------------------------------------------

  static void modules(Router router) => router.get("$_questionsApi-modules", (Request request) async {
    final String? technologyId = request.url.queryParameters["technologyId"];
    final String? stage = request.url.queryParameters['stage'];

    if(technologyId ==  null || technologyId.trim().isEmpty){
      return Response.badRequest(body: "Technology Id parameter is missing".errorStatus);
    } else if(stage ==  null || stage.trim().isEmpty){
      return Response.badRequest(body: "Stage parameter is missing".errorStatus);
    }

    try {
      final (String, String) technologyInfo = await HomeService.getTechnologyInfoById(technologyId);
      final Modules modules = await HomeService.getModules(technologyId, stage);

      return Response.ok(jsonEncode({
        "title": technologyInfo.$1,
        "stage": stage,
        "imageUrl": technologyInfo.$2,
        "modules": modules.toJson
      }));
    } catch(e){
      if(e == "Bad state: No element"){
        return Response.notFound("No element".errorStatus);
      } else {
        return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
      }
    }
  });

  static void addModule(Router router) => router.post("$_questionsApi-add-module", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.isEmpty) {
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(!ModuleDto.isValid(jsonDecode(requestBody))){
        return Response.badRequest(body: "Invalid body".errorStatus);
      }

      final ModuleDto dto = ModuleDto.fromJson(jsonDecode(requestBody));
      await QuestionsService.storageModule(dto);

      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void deleteModule(Router router) => router.delete("$_questionsApi-delete-module", (Request request) async {
    final String? id = request.url.queryParameters["id"];

    if(id ==  null || id.trim().isEmpty){
      return Response.badRequest(body: "Id parameter is missing".errorStatus);
    }

    try {
      await QuestionsService.deleteModule(id);
      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });



  /// department ---------------------------------------------------------------------------------------

  static void addDepartment(Router router) => router.post("$_questionsApi-add-department", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.isEmpty) {
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(!DepartmentDto.isValid(jsonDecode(requestBody))){
        return Response.badRequest(body: "Invalid body".errorStatus);
      }

      final DepartmentDto dto = DepartmentDto.fromJson(jsonDecode(requestBody));
      await QuestionsService.storageDepartment(dto);

      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void updateDepartment(Router router) => router.put("$_questionsApi-update-department", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.isEmpty) {
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(!DepartmentUpdateDto.isValid(jsonDecode(requestBody))){
        return Response.badRequest(body: "Invalid body".errorStatus);
      }

      final DepartmentUpdateDto dto = DepartmentUpdateDto.fromJson(jsonDecode(requestBody));
      await QuestionsService.updateDepartment(dto);

      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void deleteDepartment(Router router) => router.delete("$_questionsApi-delete-department", (Request request) async {
    final String? id = request.url.queryParameters["id"];

    if(id ==  null || id.trim().isEmpty){
      return Response.badRequest(body: "Id parameter is missing".errorStatus);
    }

    try {
      await QuestionsService.deleteDepartment(id);
      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });




  /// question -----------------------------------------------------------------------------------------

  static void questions(Router router) => router.get("$_questionsApi-get-questions", (Request request) async {
    final String? departmentId = request.url.queryParameters["departmentId"];

    if(departmentId ==  null || departmentId.trim().isEmpty){
      return Response.badRequest(body: "Technology Id parameter is missing".errorStatus);
    }

    try {
      final List<Question> questions = await HomeService.getQuestions(departmentId);
      return Response.ok(jsonEncode(questions.map((e) => e.toJson).toList()));
    } catch(e){
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void addQuestion(Router router) => router.post("$_questionsApi-add-question", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.isEmpty) {
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(!QuestionDto.isValid(jsonDecode(requestBody))){
        return Response.badRequest(body: "Invalid body".errorStatus);
      }

      final QuestionDto dto = QuestionDto.fromJson(jsonDecode(requestBody));
      await QuestionsService.storageQuestion(dto);

      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void updateQuestion(Router router) => router.put("$_questionsApi-update-question", (Request request) async {
    final String? contentType = request.headers["content-type"];
    final String requestBody = await request.readAsString();

    try {
      if(contentType == null || contentType.toLowerCase() != "application/json"){
        return Response.badRequest(body: "Content-Type header must be application/json".errorStatus);
      } else if(requestBody.trim().isEmpty) {
        return Response.badRequest(body: "Empty request body".errorStatus);
      } else if(!QuestionUpdateDto.isValid(jsonDecode(requestBody))){
        return Response.badRequest(body: "Body is invalid");
      }

      final QuestionUpdateDto dto = QuestionUpdateDto.fromJson(jsonDecode(requestBody));
      await QuestionsService.updateQuestion(dto);
      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });

  static void deleteQuestion(Router router) => router.delete("$_questionsApi-delete-question", (Request request) async {
    final String? id = request.url.queryParameters["id"];

    if(id ==  null || id.trim().isEmpty){
      return Response.badRequest(body: "Id parameter is missing".errorStatus);
    }

    try {
      await QuestionsService.deleteQuestion(id);
      return Response.ok("OK");
    } catch(e) {
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }
  });
}
