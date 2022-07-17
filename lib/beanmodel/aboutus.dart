class AboutUsMain{
  dynamic status;
  dynamic message;
  AboutUsData data;

  AboutUsMain(this.status, this.message, this.data);

  factory AboutUsMain.fromJsom(dynamic json){
    AboutUsData d = AboutUsData.fromJson(json['data']);
    return AboutUsMain(json['status'], json['message'], d);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class AboutUsData{
  dynamic aboutId;
  dynamic title;
  dynamic description;

  AboutUsData(this.aboutId, this.title, this.description);

  factory AboutUsData.fromJson(dynamic json){
    return AboutUsData(json['about_id'], json['title'], json['description']);
  }

  @override
  String toString() {
    return '{about_id: $aboutId, title: $title, description: $description}';
  }
}