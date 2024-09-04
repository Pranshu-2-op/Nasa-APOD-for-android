import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class SkeletonLoader extends StatelessWidget {
  final String svgAssetPath;
  final bool isLoading;
  final double height;
  final double width;

  const SkeletonLoader({
    super.key,
    required this.svgAssetPath,
    this.isLoading = true,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isLoading)
          FutureBuilder<Path>(
            future: _loadSvgPath(context, svgAssetPath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  width: width,
                  height: height,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return const SizedBox.shrink();
              } else {
                final path = snapshot.data!;
                return CustomPaint(
                  size: Size(width, height),
                  painter: SkeletonPainter(path),
                );
              }
            },
          ),
        if (!isLoading)
          SvgPicture.asset(
            svgAssetPath,
            height: height,
            width: width,
          ),
      ],
    );
  }

  Future<Path> _loadSvgPath(BuildContext context, String assetPath) async {
    final String svgString = await rootBundle.loadString(assetPath);
    final Path path = _parseSvgPath(svgString);
    return path;
  }

  Path _parseSvgPath(String svgString) {
    // This is a placeholder; implement SVG parsing if needed
    return Path()..addRect(Rect.fromLTWH(0, 0, width, height));
  }
}

class SkeletonPainter extends CustomPainter {
  final Path svgPath;

  SkeletonPainter(this.svgPath);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    // Draw the SVG path with skeleton effect
    canvas.drawPath(svgPath, paint);

    // Optionally, add gradient or shimmer effect here
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
