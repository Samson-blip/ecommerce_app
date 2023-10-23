import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200.0, // Adjust the height as needed
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                width: 100.0,
                height: 10.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}