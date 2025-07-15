import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          Positioned(
            left: 6,
            top: 5,
            bottom: 5,
            child: Container(
              width: 28,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          // Positioned(
          //   right: 6,
          //   top: 5,
          //   bottom: 5,
          //   child: Container(
          //     width: 28,
          //     decoration: BoxDecoration(
          //       color: const Color.fromARGB(255, 32, 211, 234),
          //       borderRadius: BorderRadius.circular(7),
          //     ),
          //   ),
          // ),
          Center(
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.add, color: Colors.black, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
