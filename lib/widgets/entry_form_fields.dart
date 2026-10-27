import 'package:flutter/material.dart';
import '../core/app_sizes.dart';
import '../models/status_collection_enum.dart';
import '../models/media_type_enum.dart';

class EntryFormFields extends StatelessWidget {
  final JenisMedia jenisMedia;
  final GlobalKey<FormState> formKey;
  final StatusKoleksi status;
  final ValueChanged<StatusKoleksi> onStatusChanged;
  final int progres;
  final ValueChanged<int> onProgresChanged;
  final TextEditingController totalController;
  final int? rating;
  final ValueChanged<int?> onRatingChanged;
  final TextEditingController catatanController;
  final bool isSaving;
  final VoidCallback onSimpan;
  final String buttonText;

  const EntryFormFields({
    super.key,
    required this.jenisMedia,
    required this.formKey,
    required this.status,
    required this.onStatusChanged,
    required this.progres,
    required this.onProgresChanged,
    required this.totalController,
    required this.rating,
    required this.onRatingChanged,
    required this.catatanController,
    required this.isSaving,
    required this.onSimpan,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<StatusKoleksi>(
            initialValue: status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: StatusKoleksi.values.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s.label(jenisMedia)),
              );
            }).toList(),
            onChanged: (val) => val != null ? onStatusChanged(val) : null,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: progres.toString(),
                  decoration: InputDecoration(
                    labelText: 'Progres (${jenisMedia.satuanProgres})',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => onProgresChanged(int.tryParse(val) ?? 0),
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
                  controller: totalController,
                  decoration: const InputDecoration(
                    labelText: 'Total',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val != null && val.isNotEmpty && int.tryParse(val) == null) {
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
            initialValue: rating,
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
            onChanged: onRatingChanged,
          ),
          const SizedBox(height: AppSizes.spacingM),
          TextFormField(
            controller: catatanController,
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
              onPressed: isSaving ? null : onSimpan,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}