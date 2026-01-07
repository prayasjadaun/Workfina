class BannerModel {
  final String title;
  final String buttonText;
  final String image;

  BannerModel({
    required this.title,
    required this.buttonText,
    required this.image,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      title: json['title'],
      buttonText: json['button_text'],
      image: json['image'],
    );
  }
}
