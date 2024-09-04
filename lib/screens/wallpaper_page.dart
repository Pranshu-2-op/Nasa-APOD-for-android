import 'dart:isolate';
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nasa_space_images/models/apod_model.dart';

class ApodScreen extends ConsumerWidget {
  final ApodModel apodModel;
  final int index;

  const ApodScreen({super.key, required this.apodModel, required this.index});

  static Route route({required ApodModel apodModel, required int index}) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Hero(
            tag: "wallpaper $index",
            child: ApodScreen(apodModel: apodModel, index: index)),
        transitionDuration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverlayVisible = ref.watch(overlayVisibilityProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
              onTap: () {
                ref.read(overlayVisibilityProvider.notifier).toggleVisibility();
              },
              child: CachedNetworkImage(
                imageUrl: apodModel.hdurl!,
                fit: BoxFit.cover,
                // placeholder: (context, url) => Center(
                //   child: CircularProgressIndicator(),
                // ),
                progressIndicatorBuilder: (context, url, downloadProgress) {
                  return Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress
                          .progress, // Show the loading progress
                    ),
                  );
                },
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              )),
          // Animated Overlay content
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: isOverlayVisible ? 0 : -800, // Animate up/down
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Color.fromARGB(110, 0, 0, 0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apodModel.title!,
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(194, 239, 255, 252))),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    apodModel.explanation ?? "No explanation",
                    style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Color.fromARGB(194, 224, 236, 255))),
                  ),
                ],
              ),
            ),
          ),
          // Animated Button at the bottom
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: isOverlayVisible ? -100 : 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _setWallpaperUsingIsolate(apodModel.hdurl!);
                },
                child: const Text("Set as Wallpaper on both screens"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OverlayVisibilityNotifier extends StateNotifier<bool> {
  OverlayVisibilityNotifier() : super(true);

  void toggleVisibility() {
    state = !state;
  }
}

final overlayVisibilityProvider =
    StateNotifierProvider<OverlayVisibilityNotifier, bool>(
        (ref) => OverlayVisibilityNotifier());

void setWallpaperInIsolate(List<dynamic> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Extract the arguments
  SendPort sendPort = args[0];
  String url = args[1];
  RootIsolateToken rootIsolateToken = args[2];

  // Ensure the isolate is properly initialized for platform channel communication
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

  try {
    // Set the wallpaper using the provided URL
    bool result = await AsyncWallpaper.setWallpaper(
      url: url,
      wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
    );

    // Send the result back to the main thread
    sendPort.send(result);
  } catch (e) {
    // Log the error\
    sendPort.send(false); // Send failure if an exception occurs
  }
}

Future<void> _setWallpaperUsingIsolate(String url) async {
  WidgetsFlutterBinding.ensureInitialized();
  final receivePort = ReceivePort();

  // Get the RootIsolateToken from the main isolate
  final rootIsolateToken = RootIsolateToken.instance!;

  try {
    // Pass the SendPort, the URL, and the RootIsolateToken to the isolate
    await Isolate.spawn(
        setWallpaperInIsolate, [receivePort.sendPort, url, rootIsolateToken]);

    // Await the result from the isolate
    final result = await receivePort.first;

    // Handle the result (e.g., showing a success or failure message)
    if (result == true) {
      print('Wallpaper set successfully!');
    } else {
      print('Failed to set wallpaper.');
    }
  } catch (e) {
    // Handle any errors that might occur during the isolate spawning or message passing
    print('Error in isolate communication: $e');
  }
}
