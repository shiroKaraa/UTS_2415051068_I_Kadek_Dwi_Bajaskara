import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/app_sizes.dart';
import '../../../models/status_collection_enum.dart';
import '../../../models/media_type_enum.dart';
import '../../../models/custom_label.dart';

class EntryFormFields extends StatelessWidget {
  final JenisMedia jenisMedia;
  final GlobalKey<FormState> formKey;
  final StatusKoleksi status;
  final ValueChanged<StatusKoleksi> onStatusChanged;
  final TextEditingController progresController;
  final TextEditingController totalController;
  final int? rating;
  final ValueChanged<int?> onRatingChanged;
  final TextEditingController catatanController;
  final bool isSaving;
  final VoidCallback onSimpan;
  final String buttonText;
  final VoidCallback? onDirty;
  final List<LabelKustom> labels;
  final int? selectedLabelId;
  final ValueChanged<int?> onLabelChanged;

  const EntryFormFields({
    super.key,
    required this.jenisMedia,
    required this.formKey,
    required this.status,
    required this.onStatusChanged,
    required this.progresController,
    required this.totalController,
    required this.rating,
    required this.onRatingChanged,
    required this.catatanController,
    required this.isSaving,
    required this.onSimpan,
    required this.buttonText,
    required this.labels,
    required this.selectedLabelId,
    required this.onLabelChanged,
    this.onDirty,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      onChanged: onDirty,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labels.isNotEmpty) ...[
            DropdownButtonFormField<int>(
              key: ValueKey('label_$selectedLabelId'),
              initialValue: selectedLabelId,
              decoration: InputDecoration(
                labelText: l10n.categoryName,
                border: const OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('-')),
                ...labels.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.nama),
                    )),
              ],
              onChanged: onLabelChanged,
            ),
            const SizedBox(height: AppSizes.spacingM),
          ],
          DropdownButtonFormField<StatusKoleksi>(
            key: ValueKey('status_$status'),
            initialValue: status,
            decoration: InputDecoration(
              labelText: l10n.fieldStatus,
              border: const OutlineInputBorder(),
            ),
            items: StatusKoleksi.values.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text(s.label(jenisMedia, l10n)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onStatusChanged(val);
            },
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: progresController,
                  decoration: InputDecoration(
                    labelText: l10n.fieldProgressUnit(
                        jenisMedia.satuanProgres(l10n)),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return l10n.fieldRequired;
                    }
                    final parsed = int.tryParse(val);
                    if (parsed == null) return l10n.fieldMustBeNumber;
                    if (parsed < 0) return l10n.fieldNotNegative;
                    final total = int.tryParse(totalController.text);
                    if (total != null && parsed > total) {
                      return l10n.fieldExceedsTotal;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: TextFormField(
                  controller: totalController,
                  decoration: InputDecoration(
                    labelText: l10n.fieldTotal,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  onChanged: (_) => formKey.currentState?.validate(),
                  validator: (val) {
                    if (val == null || val.isEmpty) return null;
                    final parsed = int.tryParse(val);
                    if (parsed == null) return l10n.fieldMustBeNumber;
                    if (parsed < 1) return l10n.fieldMustBeNumber;
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          DropdownButtonFormField<int>(
            key: ValueKey('rating_$rating'),
            initialValue: rating,
            decoration: InputDecoration(
              labelText: l10n.fieldRating,
              border: const OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('-')),
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
            decoration: InputDecoration(
              labelText: l10n.fieldNote,
              border: const OutlineInputBorder(),
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