import 'package:flutter/material.dart';
import 'package:clipzy/constants.dart';
import 'package:clipzy/views/widgets/custom_icon.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIdx = 0;

  final List<IconData?> icons = [
    Ionicons.home_outline, // Sleek home icon
    Feather.search, // Thin elegant search icon
    null, // For center action button
    Ionicons.chatbubble_outline, // Messages icon
    FontAwesome.user_circle_o, // Profile icon
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      // Floating bottom bar with padding and rounded edges
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            if (index == 2) {
              // Middle custom floating button
              return GestureDetector(
                onTap: () {
                  setState(() {
                    pageIdx = 2;
                  });
                },
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: buttonColor.withOpacity(0.6),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomIcon(),
                ),
              );
            } else {
              // Other icons
              bool isSelected = pageIdx == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    pageIdx = index;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[index],
                      size: 28,
                      color: isSelected ? Colors.purpleAccent : Colors.white70,
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 3,
                      width: isSelected ? 20 : 0,
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ),
      body: pages[pageIdx],
    );
  }
}
