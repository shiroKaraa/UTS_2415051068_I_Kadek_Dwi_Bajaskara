import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_sizes.dart';
import '../models/collection_entry.dart';
import '../models/status_collection_enum.dart';
import '../providers/collection_provider.dart';

class EditEntryPage extends StatefulWidget {
  final EntriKoleksi entri;

  const EditEntryPage({super.key, required this.entri});

  @override
  State<EditEntryPage> createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  final _formKey = GlobalKey<FormState>();
  late StatusKoleksi _status;
  late int _progres;
  late TextEditingController _totalController;
  late TextEditingController _catatanController;
  int? _rating;

  @override
  void initState() {
    super.initState();
    _status = widget.entri.status;
    _progres = widget.entri.progres;
    _totalController = TextEditingController(
      text: widget.entri.total?.toString() ?? '',
    );
    _catatanController = TextEditingController(text: widget.entri.catatan ?? '');
    _rating = widget.entri.rating;
  }

  @override
  void dispose() {
    _totalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final collection = context.read<CollectionProvider>();

    final entriUpdate = widget.entri.copyWith(
      status: _status,
      progres: _progres,
      total: int.tryParse(_totalController.text),
      rating: _rating,
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
      updatedAt: DateTime.now(),
    );

    final berhasil = await collection.updateEntry(entriUpdate);

    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil diperbarui!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(collection.errorMessage ?? 'Gagal menyimpan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = context.watch<CollectionProvider>();
    final isSaving = collection.isSaving;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Entri')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: widget.entri.coverUrl != null
                      ? Image.network(widget.entri.coverUrl!,
                          width: 40, height: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Text(widget.entri.judul),
                  subtitle: Text(
                    '${widget.entri.jenis.label} • ${widget.entri.total ?? "?"} ${widget.entri.jenis.satuanProgres}',
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              DropdownButtonFormField<StatusKoleksi>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: StatusKoleksi.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.label(widget.entri.jenis)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: AppSizes.spacingM),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _progres.toString(),
                      decoration: InputDecoration(
                        labelText:
                            'Progres (${widget.entri.jenis.satuanProgres})',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) =>
                          _progres = int.tryParse(val) ?? 0,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        final num = int.tryParse(val);
                        if (num == null) return 'Harus angka';
                        if (num < 0) return 'Tidak boleh negatif';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingS),
                  Expanded(
                    child: TextFormField(
                      controller: _totalController,
                      decoration: const InputDecoration(
                        labelText: 'Total',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val != null &&
                            val.isNotEmpty &&
                            int.tryParse(val) == null) {
                          return 'Harus angka';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingM),
              DropdownButtonFormField<int>(
                initialValue: _rating,
                decoration: const InputDecoration(
                  labelText: 'Rating (Opsional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tidak ada')),
                  ...List.generate(5, (i) => i + 1).map((val) {
                    return DropdownMenuItem(
                      value: val,
                      child: Text('⭐' * val),
                    );
                  }),
                ],
                onChanged: (val) => setState(() => _rating = val),
              ),
              const SizedBox(height: AppSizes.spacingM),
              TextFormField(
                controller: _catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.spacingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _simpan,
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}