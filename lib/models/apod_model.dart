// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ApodModel {
  String? title;
  String? url;
  String? explanation;
  String? date;
  String? media_type;
  String? hdurl;
  ApodModel({
    this.title,
    this.url,
    this.explanation,
    this.date,
    this.media_type,
    this.hdurl,
  });

  ApodModel copyWith({
    String? title,
    String? url,
    String? explanation,
    String? date,
    String? media_type,
    String? hdurl,
  }) {
    return ApodModel(
      title: title ?? this.title,
      url: url ?? this.url,
      explanation: explanation ?? this.explanation,
      date: date ?? this.date,
      media_type: media_type ?? this.media_type,
      hdurl: hdurl ?? this.hdurl,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'url': url,
      'explanation': explanation,
      'date': date,
      'media_type': media_type,
      'hdurl': hdurl,
    };
  }

  factory ApodModel.fromMap(Map<String, dynamic> map) {
    return ApodModel(
      title: map['title'] != null ? map['title'] as String : null,
      url: map['url'] != null ? map['url'] as String : null,
      explanation:
          map['explanation'] != null ? map['explanation'] as String : null,
      date: map['date'] != null ? map['date'] as String : null,
      media_type:
          map['media_type'] != null ? map['media_type'] as String : null,
      hdurl: map['hdurl'] != null ? map['hdurl'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  // Corrected factory constructor
  factory ApodModel.fromJson(Map<String, dynamic> source) =>
      ApodModel.fromMap(source);

  @override
  String toString() {
    return 'ApodModel(title: $title, url: $url, explanation: $explanation, date: $date, media_type: $media_type, hdurl: $hdurl)';
  }

  @override
  bool operator ==(covariant ApodModel other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.url == url &&
        other.explanation == explanation &&
        other.date == date &&
        other.media_type == media_type &&
        other.hdurl == hdurl;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        url.hashCode ^
        explanation.hashCode ^
        date.hashCode ^
        media_type.hashCode ^
        hdurl.hashCode;
  }
}
