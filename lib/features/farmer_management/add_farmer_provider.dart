import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/models/picked_media.dart';
import '../farm_management/polygon_drawing_tool/utils/bytes_to_size.dart';

class AddFarmerProvider extends ChangeNotifier {


    final projectIdController = TextEditingController();
    final farmerNameController = TextEditingController();
    final farmerIdNumberController = TextEditingController();
    final farmerGenderController = TextEditingController();
    final farmerDOBController = TextEditingController();
    final farmerPhoneNumber = TextEditingController();

    String? _selectedProjectID;

    // Getters
    String? get selectedProjectID => _selectedProjectID;

    void setSelectedRegion(String? regionId) {
        debugPrint("VALUE:::::: $regionId");
        _selectedProjectID = regionId;
        notifyListeners();
    }

    setSelectedProject(String val){
        _selectedProjectID = val;
        projectIdController.text = val;
    }


    final List<String> projectIDs = [
        "project 1",
        "project 2",
        "project 3",
    ];

    final ImagePicker mediaPicker = ImagePicker();
    PickedMedia? farmerPhoto;


    pickMedia({int? source}) async {
        final XFile? mediaFile;
        var fileType = "image";
        if (source == 0) {
            mediaFile = await mediaPicker.pickImage(
                source: ImageSource.gallery, imageQuality: 50);
        } else {
            mediaFile = await mediaPicker.pickImage(
                source: ImageSource.camera, imageQuality: 50);
        }

        if (mediaFile != null) {
            var fileSize = await mediaFile.length();
            PickedMedia pickedMedia = PickedMedia(
                name: mediaFile.name,
                path: mediaFile.path,
                type: fileType,
                size: fileSize,
                file: io.File(mediaFile.path),
            );
            // print('haaaaaaaaaaaaaaaa');
            // print(bytesToSize(fileSize));
            farmerPhoto = pickedMedia;

            notifyListeners();
            debugPrint(bytesToSize(fileSize));
        } else {
            return null;
        }
    }
}