import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/custom_category.dart';
import '../../providers/category_provider.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  void _showFormDialog(BuildContext context, AppLocalizations l10n, [KategoriKustom? category]) {
    final namaController = TextEditingController(text: category?.nama ?? '');
    final satuanController = TextEditingController(text: category?.satuanProgres ?? 'Bagian');
    final provider = context.read<CategoryProvider>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(category == null ? l10n.addCategory : l10n.editCategory),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: l10n.categoryName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: satuanController,
              decoration: InputDecoration(labelText: l10n.progressUnit),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
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
                  SnackBar(content: Text(category == null ? l10n.categoryAdded : l10n.categoryUpdated)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.errorMessage ?? 'Terjadi kesalahan.')),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _konfirmasiHapus(BuildContext context, AppLocalizations l10n, KategoriKustom category) async {
    final provider = context.read<CategoryProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryDesc(category.nama)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final success = await provider.deleteCategory(category);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categoryDeleted)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Gagal menghapus.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageCategories)),
      body: (!provider.hasLoaded && provider.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : provider.categories.isEmpty
              ? Center(child: Text(l10n.noCategory))
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
                              onPressed: () => _showFormDialog(context, l10n, category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _konfirmasiHapus(context, l10n, category),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context, l10n),
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}