import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/coloring_canvas.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  int currentPage = 0;
  final List<String> artPages = [
    'assets/photos/Apple.png',
    'assets/photos/Banana.png',
    'assets/photos/Cat.png',
    'assets/photos/Dog.png',
    'assets/photos/Elf.png',
    'assets/photos/Fish.png',
    'assets/photos/Giraffe.png',
    'assets/photos/Horse.png',
    'assets/photos/Ice cream.png',
    'assets/photos/Jug.png',
    'assets/photos/Kite.png',
    'assets/photos/Lion.png',
    'assets/photos/Mouse.png',
    'assets/photos/Necklace.png',
    'assets/photos/Orange.png',
    'assets/photos/Pencil.png',
    'assets/photos/Queen.png',
    'assets/photos/Rose.png',
    'assets/photos/Sun.png',
    'assets/photos/Torch.png',
    'assets/photos/Umbrella.png',
    'assets/photos/Violin.png',
    'assets/photos/watch.png',
    'assets/photos/Yak.png',
    'assets/photos/Zoo.png',
  ];

  int _selectedIndex = 0;
  final GlobalKey<ColoringCanvasState> _canvasKey = GlobalKey<ColoringCanvasState>();

  void nextPage() {
    if (currentPage < artPages.length - 1) {
      setState(() {
        currentPage++;
        print('Navigated to page: ' + currentPage.toString() + ' - ' + artPages[currentPage]);
      });
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        print('Navigated to page: ' + currentPage.toString() + ' - ' + artPages[currentPage]);
      });
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) return;
    if (index == 1) Navigator.pushNamed(context, '/gallery');
    if (index == 2) Navigator.pushNamed(context, '/settings');
  }

  void saveCurrentDrawing() {
    _canvasKey.currentState?.saveImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Art Book'),
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, size: 32),
            onPressed: () => Navigator.pushNamed(context, '/gallery'),
            tooltip: 'Gallery',
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 32),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F6FF), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Big centered picture and drawing canvas
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 380,
                        height: 480,
                        child: ColoringCanvas(
                          key: _canvasKey,
                          svgAsset: artPages[currentPage],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 2, color: Colors.deepPurple, height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPage == 0 ? Colors.grey : Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        elevation: 6,
                      ),
                      icon: const Icon(Icons.arrow_back, size: 36, color: Colors.white),
                      label: const Text('Previous', style: TextStyle(fontSize: 24, color: Colors.white)),
                      onPressed: currentPage == 0 ? null : prevPage,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        elevation: 6,
                      ),
                      icon: const Icon(Icons.save_alt, size: 36, color: Colors.white),
                      label: const Text('Save', style: TextStyle(fontSize: 24, color: Colors.white)),
                      onPressed: saveCurrentDrawing,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentPage == artPages.length - 1 ? Colors.grey : Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        elevation: 6,
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 36, color: Colors.white),
                      label: const Text('Next', style: TextStyle(fontSize: 24, color: Colors.white)),
                      onPressed: currentPage == artPages.length - 1 ? null : nextPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        iconSize: 32,
        selectedFontSize: 18,
        unselectedFontSize: 16,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Book',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
