import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/book_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/art_provider.dart';

void main() {
  runApp(const ColorBookApp());
}

class ColorBookApp extends StatelessWidget {
  const ColorBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArtProvider(),
      child: MaterialApp(
        title: 'Color Book',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ).copyWith(
            primary: Colors.deepPurple,
            secondary: Colors.orangeAccent,
            background: const Color(0xFFF8F6FF),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F6FF),
          textTheme: GoogleFonts.baloo2TextTheme(
            Theme.of(context).textTheme.apply(
              bodyColor: Colors.deepPurple,
              displayColor: Colors.deepPurple,
            ),
          ).copyWith(
            titleLarge: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.bold),
            labelLarge: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const BookScreen(),
          '/gallery': (context) => const GalleryScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
