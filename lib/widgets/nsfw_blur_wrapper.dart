import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class NsfwBlurWrapper extends StatefulWidget {
  final Widget child;
  final bool isAdult;
  final bool sensorCover;
  final bool sensorText;
  final double radius;

  const NsfwBlurWrapper({
    super.key,
    required this.child,
    required this.isAdult,
    this.sensorCover = false,
    this.sensorText = false,
    this.radius = 12,
  });

  @override
  State<NsfwBlurWrapper> createState() => _NsfwBlurWrapperState();
}

class _NsfwBlurWrapperState extends State<NsfwBlurWrapper> {
  bool _revealed = false;
  bool _lastHeavy = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isAdult) return widget.child;

    final settings = context.watch<SettingsProvider>();
    final nsfw = settings.nsfw;

    if (!nsfw.enabled) return widget.child;

    final shouldBlur = widget.sensorCover
        ? nsfw.shouldSensorCover
        : (widget.sensorText ? nsfw.shouldSensorTitle : false);

    if (!shouldBlur) return widget.child;

    final heavy = nsfw.isHeavyMode;

    // Reset _revealed jika user mengubah mode dari Heavy ke Light (atau sebaliknya)
    if (_lastHeavy != heavy) {
      _lastHeavy = heavy;
      // Jangan panggil setState di dalam build.
      // Cukup ubah nilai _revealed secara langsung.
      _revealed = false; 
    }

    // Jika sudah di-reveal (baik mode light maupun heavy), tampilkan asli.
    // Long press untuk menyembunyikan kembali (blur lagi).
    if (_revealed) {
      return GestureDetector(
        onLongPress: () => setState(() => _revealed = false),
        child: widget.child,
      );
    }

    // Jika masih blur, tampilkan overlay
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          if (heavy) {
            _confirmReveal(context);
          } else {
            setState(() => _revealed = true);
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: heavy ? 24 : 14,
                  sigmaY: heavy ? 24 : 14,
                ),
                child: widget.child,
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: heavy ? 0.55 : 0.25),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              heavy
                                  ? Icons.lock_outline
                                  : Icons.visibility_off_outlined,
                              color: Colors.white,
                              size: heavy ? 28 : 22,
                            ),
                            if (heavy) ...[
                              const SizedBox(height: 4),
                              const Text(
                                '18+',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReveal(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nsfwRevealTitle),
        content: Text(l10n.nsfwRevealDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.nsfwRevealBtn),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _revealed = true);
    }
  }
}