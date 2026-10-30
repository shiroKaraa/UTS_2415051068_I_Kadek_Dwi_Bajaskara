import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../models/custom_label.dart';
import '../../providers/label_provider.dart';

class LabelPage extends StatelessWidget {
  const LabelPage({super.key});

  void _showFormDialog(BuildContext context, AppLocalizations l10n, [LabelKustom? label]) {
    showDialog(
      context: context,
      builder: (dialogCtx) => _LabelFormDialog(l10n: l10n, label: label),
    );
  }

  Future<void> _konfirmasiHapus(BuildContext context, AppLocalizations l10n, LabelKustom label) async {
    final provider = context.read<LabelProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryDesc),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final success = await provider.deleteLabel(label);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.categoryDeleted)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? l10n.categoryDeleteFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<LabelProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageCategories)),
      body: (!provider.hasLoaded && provider.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : provider.labels.isEmpty
              ? Center(child: Text(l10n.noCategory))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.spacingM),
                  itemCount: provider.labels.length,
                  itemBuilder: (context, index) {
                    final label = provider.labels[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.label_outline, color: AppColors.primaryGreen),
                        title: Text(label.nama),
                        subtitle: Text('${l10n.categoryUnitPrefix} ${label.satuanProgres}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.infoBlue),
                              onPressed: () => _showFormDialog(context, l10n, label),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _konfirmasiHapus(context, l10n, label),
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

class _LabelFormDialog extends StatefulWidget {
  final AppLocalizations l10n;
  final LabelKustom? label;

  const _LabelFormDialog({required this.l10n, this.label});

  @override
  State<_LabelFormDialog> createState() => _LabelFormDialogState();
}

class _LabelFormDialogState extends State<_LabelFormDialog> {
  late final TextEditingController _namaController;
  late final TextEditingController _satuanController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.label?.nama ?? '');
    _satuanController = TextEditingController(text: widget.label?.satuanProgres ?? 'Bagian');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _satuanController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_namaController.text.trim().isEmpty || _satuanController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    final provider = context.read<LabelProvider>();
    bool success;

    if (widget.label == null) {
      success = await provider.createLabel(_namaController.text.trim(), _satuanController.text.trim());
    } else {
      success = await provider.updateLabel(widget.label!.copyWith(
        nama: _namaController.text.trim(),
        satuanProgres: _satuanController.text.trim(),
      ));
    }

    if (!mounted) return;

    if (success) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(SnackBar(
        content: Text(widget.label == null ? widget.l10n.categoryAdded : widget.l10n.categoryUpdated),
      ));
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.errorMessage ?? widget.l10n.categoryGenericError),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.label == null ? widget.l10n.addCategory : widget.l10n.editCategory),
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
        TextButton(onPressed: _isSaving ? null : () => Navigator.pop(context), child: Text(widget.l10n.cancel)),
        ElevatedButton(
          onPressed: _isSaving ? null : _simpan,
          child: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.l10n.save),
        ),
      ],
    );
  }
}