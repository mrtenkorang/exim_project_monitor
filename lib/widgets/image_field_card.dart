import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class ImageFieldCard extends StatelessWidget {
  final Function? onTap;
  final File? image;
  final String? base64Image;
  const ImageFieldCard({super.key, this.onTap, this.image, this.base64Image});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
        backgroundColor: Theme.of(context).colorScheme.surface,
        minimumSize: const Size(0, 36),
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(10))),
      ),
      onPressed: () => onTap!(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.35,
        width: double.infinity,
        decoration: boxDecoration(),
        // decoration: image != null
        //   ? BoxDecoration(
        //     borderRadius: BorderRadius.all(Radius.circular(AppBorderRadius.sm)),
        //   image: DecorationImage(
        //       image: FileImage(image!),
        //     fit: BoxFit.cover
        //   )
        // )
        // : BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(AppBorderRadius.sm))),
        child: (image == null && (base64Image == null || base64Image!.isEmpty))
            ? Center(
                child: Icon(Icons.add_photo_alternate, size: 30, color: Theme.of(context).colorScheme.onSurface),
              )
            : Container(),
      ),
    );
  }

  BoxDecoration boxDecoration() {
    if (image != null) {
      return BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          image: DecorationImage(image: FileImage(image!), fit: BoxFit.cover));
    } else if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        return BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            image: DecorationImage(
                image: MemoryImage(base64Decode(base64Image!)),
                fit: BoxFit.cover));
      } catch (e) {
        return const BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(10)));
      }
    } else {
      return const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)));
    }
  }
}
