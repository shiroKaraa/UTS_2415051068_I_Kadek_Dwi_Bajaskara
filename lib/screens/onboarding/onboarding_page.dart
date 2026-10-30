import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../core/app_sizes.dart';
import '../../providers/settings_provider.dart';

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String desc;
  const _OnboardingSlide(this.icon, this.title, this.desc);
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get _isLast => _currentPage == 2;

  Future<void> _finishOnboarding() async {
    await context.read<SettingsProvider>().setHasSeenOnboarding(true);
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final slides = [
      _OnboardingSlide(Icons.auto_stories, l10n.onboardingTitle, l10n.onboardingDesc),
      _OnboardingSlide(Icons.track_changes, l10n.onboardingSlide2Title, l10n.onboardingSlide2Desc),
      _OnboardingSlide(Icons.collections_bookmark, l10n.onboardingSlide3Title, l10n.onboardingSlide3Desc),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const _LanguageToggle(),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: _isLast ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: _isLast,
                      child: TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(l10n.skip),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: slides.length,
                itemBuilder: (_, i) => _SlideView(slide: slides[i], theme: theme),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingXl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (i) {
                      final active = _currentPage == i;
                      return GestureDetector(
                        onTap: () => _goTo(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: active ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primaryGreen
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLast ? _finishOnboarding : () => _goTo(_currentPage + 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _isLast ? l10n.getStarted : l10n.next,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _OnboardingSlide slide;
  final ThemeData theme;
  const _SlideView({required this.slide, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(slide.icon, size: 100, color: AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: AppSizes.spacingXl),
          Text(
            slide.title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            slide.desc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isId = settings.locale.languageCode == 'id';
    return TextButton.icon(
      onPressed: () => settings.setLocale(Locale(isId ? 'en' : 'id')),
      icon: const Icon(Icons.language, size: 18),
      label: Text(isId ? 'ID' : 'EN'),
    );
  }
}