

class SecondaryCropModel {
  final String cropName;
  final int farmerId;

  SecondaryCropModel({
    required this.cropName,
    required this.farmerId,
  });

  factory SecondaryCropModel.fromJson(Map<String, dynamic> json) {
    return SecondaryCropModel(
      cropName: json['cropName'],
      farmerId: json['farmerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropName': cropName,
      'farmerId': farmerId,
    };
  }
}