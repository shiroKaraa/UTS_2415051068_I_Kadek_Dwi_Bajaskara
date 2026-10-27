import 'package:flutter/material.dart';
import 'skeleton_base.dart';

class SkeletonListCard extends StatelessWidget {
  const SkeletonListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonBase(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const SkeletonBox(width: 50, height: 70),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(height: 16, width: double.infinity),
                    const SizedBox(height: 8),
                    const SkeletonBox(height: 12, width: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}