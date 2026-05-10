import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int currentFloor = 0;
  final TransformationController _controller = TransformationController();

  static const List<_FloorInfo> floors = [
    _FloorInfo(label: 'G Floor', asset: 'assets/maps/ground.png'),
    _FloorInfo(label: '1st Floor', asset: 'assets/maps/first.png'),
    _FloorInfo(label: '2nd Floor', asset: 'assets/maps/second.png'),
    _FloorInfo(label: '3rd Floor', asset: 'assets/maps/third.png'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectFloor(int index) {
    if (currentFloor == index) {
      return;
    }

    setState(() {
      currentFloor = index;
      _controller.value = Matrix4.identity();
    });
  }

  void _zoomIn() {
    _setZoom(1.25);
  }

  void _zoomOut() {
    _setZoom(0.8);
  }

  void _resetZoom() {
    _controller.value = Matrix4.identity();
  }

  void _setZoom(double factor) {
    final next = _controller.value.clone()..scale(factor);
    final zoom = next.getMaxScaleOnAxis();

    if (zoom < 1 || zoom > 8) {
      return;
    }

    _controller.value = next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;
            final mallHeight = compact ? 162.0 : 198.0;
            final mapTopPadding = compact ? 20.0 : 36.0;

            return Column(
              children: [
                const _MapHeader(),
                const SizedBox(height: 8),
                _FloorTabs(
                  currentIndex: currentFloor,
                  floors: floors,
                  onTap: _selectFloor,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, mapTopPadding, 8, 10),
                    child: _MapViewer(
                      controller: _controller,
                      asset: floors[currentFloor].asset,
                      onZoomIn: _zoomIn,
                      onZoomOut: _zoomOut,
                      onResetZoom: _resetZoom,
                    ),
                  ),
                ),
                SizedBox(
                  height: mallHeight,
                  width: double.infinity,
                  child: const _FadedMallImage(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FloorInfo {
  const _FloorInfo({required this.label, required this.asset});

  final String label;
  final String asset;
}

class _MapHeader extends StatelessWidget {
  const _MapHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: const BoxDecoration(
        color: Color(0xFF51A2B4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(52),
          bottomRight: Radius.circular(52),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 14,
            top: 40,
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 38),
              child: Text(
                'Mall Map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorTabs extends StatelessWidget {
  const _FloorTabs({
    required this.currentIndex,
    required this.floors,
    required this.onTap,
  });

  final int currentIndex;
  final List<_FloorInfo> floors;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: List.generate(floors.length, (index) {
          final selected = currentIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(18),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: selected ? 2 : 0,
                      height: 18,
                      margin: EdgeInsets.only(right: selected ? 2 : 0),
                      color: const Color(0xFF51A2B4),
                    ),
                    Flexible(
                      child: Text(
                        floors[index].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF51A2B4)
                              : Colors.black,
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w800 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MapViewer extends StatelessWidget {
  const _MapViewer({
    required this.controller,
    required this.asset,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
  });

  final TransformationController controller;
  final String asset;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: controller,
            boundaryMargin: const EdgeInsets.all(120),
            minScale: 1,
            maxScale: 8,
            panEnabled: true,
            scaleEnabled: true,
            child: Center(
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: Column(
            children: [
              _ZoomButton(icon: Icons.add, onTap: onZoomIn),
              const SizedBox(height: 8),
              _ZoomButton(icon: Icons.remove, onTap: onZoomOut),
              const SizedBox(height: 8),
              _ZoomButton(icon: Icons.center_focus_strong, onTap: onResetZoom),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: const Color(0xFF51A2B4), size: 20),
        ),
      ),
    );
  }
}

class _FadedMallImage extends StatelessWidget {
  const _FadedMallImage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.48,
          child: Image.asset(
            'assets/images/mall.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.76),
                Colors.white.withOpacity(0.22),
              ],
              stops: const [0.0, 0.34, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}
