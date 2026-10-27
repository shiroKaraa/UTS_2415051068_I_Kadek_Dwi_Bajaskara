import 'package:flutter/material.dart';
import 'skeleton_base.dart';

class SkeletonDetailPage extends StatelessWidget {
  const SkeletonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SkeletonBase(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const SkeletonBox(width: 180, height: 270),
                ),
              ),
              const SizedBox(height: 24),
              const SkeletonBox(height: 24, width: 250),
              const SizedBox(height: 8),
              const SkeletonBox(height: 16, width: 150),
              const SizedBox(height: 24),
              const SkeletonBox(height: 100, width: double.infinity),
              const SizedBox(height: 24),
              const SkeletonBox(height: 50, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}