import 'package:flutter/material.dart';

class FeatureBox extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  const FeatureBox(
      {super.key,
      required this.title,
      required this.description,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 35,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
        ).copyWith(left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              description,
              style: const TextStyle(fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}
