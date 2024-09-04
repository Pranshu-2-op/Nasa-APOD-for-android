import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nasa_space_images/models/apod_model.dart';

final NASAApiProvider = Provider(
  (ref) => NASAApi(),
);

class NASAApi {
  static const String _apiKey = 'E184FVwWqSEGkcWyFFOsYjDxR0d07hOxhT6z9GxC';

  Future<ApodModel> fetchDailyPicture() async {
    const url = 'https://api.nasa.gov/planetary/apod?api_key=$_apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Parse the response body as a List of Maps
      final List<dynamic> jsonResponse = jsonDecode(response.body);

      // Convert the List of Maps into a List of ApodModel objects
      List<ApodModel> pictures =
          jsonResponse.map((map) => ApodModel.fromMap(map)).toList();
      return pictures.first;
    } else {
      throw Exception('Failed to load images');
    }
  }

  Future<List<ApodModel>> fetchPicture(String startDate, String endDate) async {
    final url =
        'https://api.nasa.gov/planetary/apod?api_key=$_apiKey&start_date=$startDate&end_date=$endDate';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Parse the response body as a List of Maps
      final List<dynamic> jsonResponse = jsonDecode(response.body);

      // Convert the List of Maps into a List of ApodModel objects
      List<ApodModel> pictures =
          jsonResponse.map((map) => ApodModel.fromMap(map)).toList();
      return pictures.reversed.toList();
    } else {
      throw Exception('Failed to load image');
    }
  }
}
