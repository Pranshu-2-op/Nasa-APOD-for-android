import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nasa_space_images/screens/home_page.dart';

// this will be used as notification channel id
const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '''NASA's Picture''',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserHomeView(),
    );
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        // auto start service
        autoStart: true,
        isForegroundMode: true,

        notificationChannelId:
            notificationChannelId, // this must match with notification channel you created above.
        initialNotificationTitle: 'Daily Wallpapers',
        initialNotificationContent:
            'A new space themed wallpaper will be set at 12 PM',
        foregroundServiceNotificationId: notificationId,
      ));
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Create ProviderContainer to access Riverpod providers

  // Set up the socket connection
  final socket = io.io("your-server-url", <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });

  socket.onConnect((_) {
    print('Connected. Socket ID: ${socket.id}');
  });

  socket.onDisconnect((_) {
    print('Disconnected');
  });

  socket.on("event-name", (data) {
    // Do something here like pushing a notification
    print('Received data: $data');
  });

  service.on("stop").listen((event) {
    service.stopSelf();
    print("Background process is now stopped");
  });

  service.on("start").listen((event) {});

  // Check every minute if it's 12 PM to change the wallpaper
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    DateTime now = DateTime.now();

    // Check if it's exactly 12:00 PM
    if (now.hour == 12 && now.minute == 00) {
      print("It's 12 PM. Setting the wallpaper...");

      try {
        // Fetch the daily wallpaper URL from NASA API
        String wallpaperUrl = await fetchData();

        // Set the wallpaper
        bool result = await AsyncWallpaper.setWallpaper(
          url: wallpaperUrl,
          wallpaperLocation: AsyncWallpaper.BOTH_SCREENS,
        );

        if (result) {
          print("Wallpaper changed successfully at 12 PM");
        } else {
          print("Failed to change wallpaper");
        }
      } catch (e) {
        print("Error: $e");
      }
    }

    // Emit an event to the server every second (for your other logic)
    socket.emit("event-name", "your-message");
    print("Service is successfully running ${DateTime.now().second}");
  });
}

Future<String> fetchData() async {
  const String apiKey = '';
  const String url = 'https://api.nasa.gov/planetary/apod?api_key=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the response body
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Example: Extract the URL of the image
      String imageUrl = jsonResponse['hdurl'];
      return imageUrl;

      // You can now use this URL to set the wallpaper or for other purposes
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
      return "error";
    }
  } catch (e) {
    print('Error: $e');
    return "error";
  }
}
