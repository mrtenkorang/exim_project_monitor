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
        decoration: boxDecoration(context),
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
                child: Icon(Icons.add_a_photo_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
              )
            : Container(),
      ),
    );
  }

  BoxDecoration boxDecoration(BuildContext context) {
    if (image != null) {
      return BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          image: DecorationImage(image: FileImage(image!), fit: BoxFit.cover));
    } else if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        // Handle both regular base64 strings and data URLs (data:image/...;base64,...)
        String base64Data = base64Image!;
        if (base64Image!.startsWith('data:image/')) {
          // Extract the base64 data part after the comma
          base64Data = base64Image!.split(',').last;
        }
        
        final imageBytes = base64Decode(base64Data);
        return BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            image: DecorationImage(
                image: MemoryImage(imageBytes),
                fit: BoxFit.cover));
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
            borderRadius: const BorderRadius.all(Radius.circular(10)));
      }
    } else {
      return BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          borderRadius: const BorderRadius.all(Radius.circular(10)));
    }
  }
}
