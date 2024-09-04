import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nasa_space_images/controller/apod_controller.dart';
import 'package:nasa_space_images/models/apod_model.dart';
import 'package:nasa_space_images/models/list_photos.dart';
import 'package:nasa_space_images/screens/wallpaper_page.dart';
import 'package:nasa_space_images/widgets/loader.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UserHomeView extends ConsumerStatefulWidget {
  const UserHomeView({super.key});

  static route() {
    return MaterialPageRoute(
      builder: (context) => const UserHomeView(),
    );
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends ConsumerState<UserHomeView> {
  final ScrollController _scrollController = ScrollController();
  DateTime _lastFetchedDate = DateTime.now();
  bool _isFetching = false;

  @override
  void initState() {
    ;
    super.initState();
    _fetchInitialImages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchInitialImages() async {
    await _fetchMoreImages();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchMoreImages();
    }
  }

  Future<void> _fetchMoreImages() async {
    if (_isFetching) return; // Prevent multiple simultaneous fetches
    _isFetching = true;

    // Calculate the end date for fetching images (one day before the last fetched date)
    final endDate = _lastFetchedDate;

    // Calculate the start date for fetching images (20 days before the end date)
    final startDate = endDate
        .subtract(const Duration(days: 26))
        .toIso8601String()
        .split('T')
        .first;

    final endDateString = endDate.toIso8601String().split('T').first;

    try {
      // Fetch images from the API within the calculated date range
      await ref.read(apodControllerProvider.notifier).fetchImages(
            context,
            startDate,
            endDateString,
            ref,
          );
      // Update the last fetched date to the new end date
      _lastFetchedDate = endDate.subtract(const Duration(days: 26));
    } finally {
      _isFetching = false;
    }
  }

  void _launchURL() async {
    try {
      await launchUrlString('https://pranshu2op.pythonanywhere.com/updates',
          mode: LaunchMode.platformDefault);
    } catch (e) {
      // Handle the exception
      print('Could not launch the URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(apodControllerProvider);
    final apodList = ref.watch(photosNotifierProvider);

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: NasaLoader(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  double scrollOffset = _scrollController.hasClients
                      ? _scrollController.offset
                      : 0.0;
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                            const Color.fromARGB(1, 0, 148, 255),
                            const Color.fromARGB(186, 0, 149, 255),
                            (scrollOffset / 2500).clamp(0, 1),
                          )!,
                          Color.lerp(
                            const Color.fromARGB(161, 0, 94, 255),
                            const Color.fromARGB(185, 34, 0, 255),
                            (scrollOffset / 800).clamp(0, 1),
                          )!,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Foreground content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                          Color.fromRGBO(209, 242, 255, 1),
                          Color.fromARGB(255, 199, 229, 251),
                          Color.fromARGB(255, 196, 224, 255),
                          Color.fromARGB(255, 171, 214, 255),
                        ])),
                  ),
                  title: SvgPicture.asset(
                    "assets/logo.svg",
                    height: 24,
                    width: 24,
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {
                          _launchURL();
                        },
                        tooltip: "Updates",
                        icon: const Icon(Icons.system_update_alt_rounded))
                  ],
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  floating: true,
                  snap: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GradientText(
                          text: "Exploring possibilities!",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                          gradient: const LinearGradient(colors: [
                            Color.fromARGB(255, 0, 149, 255),
                            Color.fromARGB(172, 187, 51, 236),
                            Color.fromARGB(191, 255, 6, 6)
                          ]))),
                ),
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < apodList.length) {
                        final ApodModel apod = apodList[index];
                        final String imageURL = apod.url!;
                        return InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                ApodScreen.route(
                                    apodModel: apod, index: index));
                          },
                          child: Hero(
                            tag: "wallpaper $index",
                            child: Card(
                              elevation: 20,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox.expand(
                                    child: CachedNetworkImage(
                                      imageUrl: imageURL,
                                      fit: BoxFit.cover,
                                      width: 720,
                                      height: 1920,
                                      placeholder: (context, url) =>
                                          Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 720,
                                          height: 1920,
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                        child: Icon(Icons.error,
                                            color: Colors.red),
                                      ),
                                    ),
                                  )),
                            ),
                          ),
                        );
                      }
                      return null; // No additional items in the grid itself
                    },
                    childCount: apodList.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: .55,
                  ),
                ),
                // SliverToBoxAdapter to display the loader after the grid
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: NasaLoader(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, bounds.width, bounds.width, 0),
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
