import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa_space_images/models/apod_model.dart';

final photosNotifierProvider =
    NotifierProvider<PhotosNotifier, List<ApodModel>>(
  () => PhotosNotifier(),
);

class PhotosNotifier extends Notifier<List<ApodModel>> {
  @override
  List<ApodModel> build() {
    return []; // Initialize with an empty list
  }

  void addPhotos(List<ApodModel> apodModels) {
    // Filter out new photos that are not already in the state
    final newPhotos = apodModels
        .where((apod) => apod.media_type == "image" && !state.contains(apod))
        .toList();

    // Update the state with all new photos at once
    state = [...state, ...newPhotos];
  }
}
