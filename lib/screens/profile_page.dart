import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/media_type_chip.dart';
import '../widgets/status_chip.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
              child: const Text(
                'IB', 
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              'I Kadek Dwi Bajaskara',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'NIM: 2415051068',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Kelas: PTI 5A',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const Divider(height: 48),

            const Text(
              'Uji Coba Reusable Chip',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: const [
                MediaTypeChip(label: 'Anime', dotColor: AppColors.typeAnime),
                MediaTypeChip(label: 'Manga', dotColor: AppColors.typeManga),
                MediaTypeChip(label: 'Manhwa', dotColor: AppColors.typeManhwa),
                MediaTypeChip(label: 'Manhua', dotColor: AppColors.typeManhua),
                MediaTypeChip(label: 'Lainnya', dotColor: AppColors.typeLainnya),
                
                SizedBox(width: 20), 
                StatusChip(
                  label: 'Sedang',
                  backgroundColor: Color(0x336FA8E8), 
                  textColor: AppColors.infoBlue,
                ),
                StatusChip(
                  label: 'Selesai',
                  backgroundColor: Color(0x33E3B964), 
                  textColor: AppColors.goldPrimary,
                ),
                StatusChip(
                  label: 'Ditunda',
                  backgroundColor: Color(0x33FF5252), 
                  textColor: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}