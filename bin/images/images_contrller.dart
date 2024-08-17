import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../core/utils/extension.dart';
import 'images_service.dart';

class ImagesController {
  static void init(Router router) {
    images(router);
  }

  static void images(Router router) => router.get( "/api/v1/images/<id>", (Request request, String id) async {
    if(id.isEmpty){
      return Response.badRequest(body: "No ID provided".errorStatus);
    } else if(!await ImagesService.checkImageExistsById(id)){
      return Response.notFound("Image not found".errorStatus);
    }

    final Uint8List imageBytes;

    try {
      imageBytes = await ImagesService.getImageBytesById(id);
    } catch(e){
      return Response.internalServerError(body: "An unexpected error occurred".errorStatus);
    }

    return Response.ok(
      imageBytes,
      headers: {
        "Content-Type": "image/png",
        "Access-Control-Allow-Origin": "*",
      },
    );
  });
}
