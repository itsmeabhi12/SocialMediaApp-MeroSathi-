import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget cachedNetworkImageLoading(mediaUrl) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    placeholder: (context , url) => Padding(
      padding: EdgeInsets.all(20),
      child: CircularProgressIndicator(),
    ),
    errorWidget: (context , url , error)=>Icon(Icons.error),
  );
}
