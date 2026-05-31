import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int currentFloor = 0;
  final TransformationController _controller = TransformationController();
  final List<String> maps = [
    'assets/maps/ground.png',
    'assets/maps/first.png',
    'assets/maps/second.png',
    'assets/maps/third.png',
  ];

  final List<String> floorNames = [
    "Ground Floor",
    "First Floor",
    "Second Floor",
    "Third Floor",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      // ✅ BODY
      body: Stack(
        children: [
          // 🔹 Map Viewer (Zoomable)
          Positioned.fill(
            child: Stack(
              children: [
                /// 🔹 Blurred Background (fix ugly empty space)
                Positioned.fill(
                  child: Image.asset(
                    maps[currentFloor],
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.4),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),

                /// 🔹 Zoomable Map (fixed zoom)
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: 1,
                    maxScale: 6,
                    panEnabled: true,
                    scaleEnabled: true,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          maps[currentFloor],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Top Title
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                floorNames[currentFloor],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 110,
            child: FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              onPressed: () {
                _controller.value = Matrix4.identity();
              },
              child: const Icon(Icons.center_focus_strong),
            ),
          ),
        ],
      ),

      // ✅ FIXED FOOTER
      bottomNavigationBar: _buildFloorSelector(),
    );
  }

  // 🔹 Floor Selector Buttons
  Widget _buildFloorSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(maps.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  currentFloor = index;
                  _controller.value = Matrix4.identity(); // ✅ reset zoom
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: currentFloor == index
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        )
                      : null,
                  color: currentFloor == index ? null : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  floorNames[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: currentFloor == index ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
