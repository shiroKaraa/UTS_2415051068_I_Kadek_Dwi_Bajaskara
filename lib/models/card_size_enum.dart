import '../l10n/app_localizations.dart';

enum CardSize {
  small,
  medium,
  large,
  custom;

  double get maxExtent {
    switch (this) {
      case CardSize.small:
        return 120.0;
      case CardSize.medium:
        return 160.0;
      case CardSize.large:
        return 200.0;
      case CardSize.custom:
        return 160.0;
    }
  }

  double get textExtra {
    switch (this) {
      case CardSize.small:
        return 56.0;
      case CardSize.medium:
        return 64.0;
      case CardSize.large:
        return 76.0;
      case CardSize.custom:
        return 64.0;
    }
  }

  String label([AppLocalizations? l10n]) {
    switch (this) {
      case CardSize.small:
        return l10n?.cardSizeSmall ?? 'Kecil';
      case CardSize.medium:
        return l10n?.cardSizeMedium ?? 'Sedang';
      case CardSize.large:
        return l10n?.cardSizeLarge ?? 'Besar';
      case CardSize.custom:
        return 'Kustom';
    }
  }
}