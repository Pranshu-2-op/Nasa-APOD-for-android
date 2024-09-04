import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa_space_images/api/nasa_api.dart';
import 'package:nasa_space_images/models/list_photos.dart';

// StateNotifier to manage fetching APOD images
final apodControllerProvider = StateNotifierProvider<ApodController, bool>(
  (ref) => ApodController(nasaApi: ref.read(NASAApiProvider)),
);

class ApodController extends StateNotifier<bool> {
  final NASAApi _nasaApi;
  ApodController({required NASAApi nasaApi})
      : _nasaApi = nasaApi,
        super(false);

  // Fetches 20 images from NASA's API on every call
  Future<void> fetchImages(
      BuildContext context, String startDate, endDate, WidgetRef ref) async {
    // Set state to loading
    try {
      state = false;
      // final now = DateTime.now();
      // final endDate = now.toIso8601String().split('T').first;
      // final startDate =
      //     now.subtract(Duration(days: 20)).toIso8601String().split('T').first;

      final apodList = await _nasaApi.fetchPicture(startDate, endDate);

      ref.read(photosNotifierProvider.notifier).addPhotos(apodList);

      state = false; // Update loading state
    } catch (error) {
      state = false; // Handle any error;
    }
  }
}
