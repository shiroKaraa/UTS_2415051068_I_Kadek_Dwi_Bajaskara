import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/custom_category.dart';
import '../../providers/category_provider.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  void _showFormDialog(BuildContext context, AppLocalizations l10n,
      [KategoriKustom? category]) {
    showDialog(
      context: context,
      builder: (dialogCtx) => _CategoryFormDialog(
        l10n: l10n,
        category: category,
      ),
    );
  }

  Future<void> _konfirmasiHapus(
      BuildContext context, AppLocalizations l10n, KategoriKustom category) async {
    final provider = context.read<CategoryProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryDesc),
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
        SnackBar(
            content:
                Text(provider.errorMessage ?? l10n.categoryDeleteFailed)),
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
                        leading: const Icon(Icons.folder_outlined,
                            color: AppColors.primaryGreen),
                        title: Text(category.nama),
                        subtitle: Text(
                            '${l10n.categoryUnitPrefix} ${category.satuanProgres}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: AppColors.infoBlue),
                              onPressed: () =>
                                  _showFormDialog(context, l10n, category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () =>
                                  _konfirmasiHapus(context, l10n, category),
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

class _CategoryFormDialog extends StatefulWidget {
  final AppLocalizations l10n;
  final KategoriKustom? category;

  const _CategoryFormDialog({required this.l10n, this.category});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late final TextEditingController _namaController;
  late final TextEditingController _satuanController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.category?.nama ?? '');
    _satuanController = TextEditingController(
        text: widget.category?.satuanProgres ?? 'Bagian');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _satuanController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_namaController.text.trim().isEmpty ||
        _satuanController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<CategoryProvider>();
    bool success;

    if (widget.category == null) {
      success = await provider.createCategory(
        _namaController.text.trim(),
        _satuanController.text.trim(),
      );
    } else {
      success = await provider.updateCategory(
        widget.category!.copyWith(
          nama: _namaController.text.trim(),
          satuanProgres: _satuanController.text.trim(),
        ),
      );
    }

    if (!mounted) return;

    if (success) {
      final messenger = ScaffoldMessenger.of(context); 
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(widget.category == null
              ? widget.l10n.categoryAdded
              : widget.l10n.categoryUpdated),
        ),
      );
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              provider.errorMessage ?? widget.l10n.categoryGenericError),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null
          ? widget.l10n.addCategory
          : widget.l10n.editCategory),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: widget.l10n.categoryName),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _satuanController,
              decoration: InputDecoration(labelText: widget.l10n.progressUnit),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _isSaving ? null : _simpan(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(widget.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _simpan,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.l10n.save),
        ),
      ],
    );
  }
}