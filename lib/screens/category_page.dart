import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../core/app_sizes.dart';
import '../models/custom_category.dart';
import '../providers/category_provider.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  void _showFormDialog(BuildContext context, [KategoriKustom? category]) {
    final namaController = TextEditingController(text: category?.nama ?? '');
    final satuanController = TextEditingController(text: category?.satuanProgres ?? 'Bagian');
    final provider = context.read<CategoryProvider>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(category == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Kategori'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: satuanController,
              decoration: const InputDecoration(
                labelText: 'Satuan Progres (misal: Bagian, Halaman, Tugas)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaController.text.trim().isEmpty || satuanController.text.trim().isEmpty) {
                return;
              }
              bool success;
              if (category == null) {
                success = await provider.createCategory(
                  namaController.text.trim(), 
                  satuanController.text.trim(),
                );
              } else {
                success = await provider.updateCategory(
                  category.copyWith(
                    nama: namaController.text.trim(),
                    satuanProgres: satuanController.text.trim(),
                  ),
                );
              }
              if (!context.mounted) return;
              if (success) {
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(category == null ? 'Kategori ditambahkan.' : 'Kategori diperbarui.')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.errorMessage ?? 'Terjadi kesalahan.')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _konfirmasiHapus(BuildContext context, KategoriKustom category) async {
    final provider = context.read<CategoryProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text(
          'Menghapus kategori "${category.nama}" akan menghapus semua entri di dalamnya. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final success = await provider.deleteCategory(category);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori dihapus.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Gagal menghapus.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kategori')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.categories.isEmpty
              ? const Center(child: Text('Belum ada kategori kustom.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.spacingM),
                  itemCount: provider.categories.length,
                  itemBuilder: (context, index) {
                    final category = provider.categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.folder_outlined, color: AppColors.primaryGreen),
                        title: Text(category.nama),
                        subtitle: Text('Satuan: ${category.satuanProgres}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.infoBlue),
                              onPressed: () => _showFormDialog(context, category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _konfirmasiHapus(context, category),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}