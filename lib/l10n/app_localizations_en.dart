// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tsuzuki';

  @override
  String get navHome => 'Home';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navCollection => 'Collection';

  @override
  String get navOther => 'Others';

  @override
  String get navProfile => 'Profile';

  @override
  String get welcome => 'Hello, Welcome!';

  @override
  String get subWelcome => 'Keep track of your watch and read progress.';

  @override
  String get continueWatching => 'Continue';

  @override
  String get popularAnime => 'Popular Anime';

  @override
  String get popularManga => 'Popular Manga';

  @override
  String get seeAll => 'See All';

  @override
  String get searchHint => 'Search title...';

  @override
  String get addToCollection => 'Add to Collection';

  @override
  String get emptyCollection => 'Collection Empty';

  @override
  String get emptyCollectionDesc =>
      'Search titles in Catalog and add your first one.';

  @override
  String get statTotal => 'Total';

  @override
  String get statReading => 'Ongoing';

  @override
  String get statCompleted => 'Completed';

  @override
  String get noTrackedYet => 'Nothing tracked yet.';

  @override
  String get searchFirst => 'Find your first anime or comic.';

  @override
  String get searchNow => 'Search Now';

  @override
  String get progress => 'Progress';

  @override
  String get onboardingTitle => 'Welcome to Tsuzuki';

  @override
  String get onboardingDesc => 'Track your favorite Anime and Comic progress.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get filterCatalog => 'Filter Catalog';

  @override
  String get allGenres => 'All Genres';

  @override
  String get allYears => 'All Years';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get searchInCollection => 'Search in your collection...';

  @override
  String get activeFilter => 'Active Filter';

  @override
  String get clearAll => 'Clear All';

  @override
  String get offlineMode => 'Offline Mode: Showing saved data.';

  @override
  String get noResults => 'No Results';

  @override
  String get noResultsDesc => 'Try changing keywords or search filters.';

  @override
  String get resetFilter => 'Reset Filter';

  @override
  String get synopsis => 'Synopsis';

  @override
  String get noSynopsis => 'No synopsis available.';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get undo => 'Undo';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'App Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'Follow System';

  @override
  String get language => 'Language';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get backupDesc => 'Export or import your collection';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get statistics => 'Statistics';

  @override
  String get storage => 'Data & Storage';

  @override
  String get about => 'About';

  @override
  String get help => 'Help';

  @override
  String get profile => 'Profile';

  @override
  String get totalTitles => 'Total Titles';

  @override
  String get completed => 'Completed';

  @override
  String get estimatedTime => 'Estimated Watch Time';

  @override
  String get days => 'Days';

  @override
  String get activityDetails => 'Activity Details';

  @override
  String get anime => 'Anime';

  @override
  String trackedTitles(Object count) {
    return '$count Titles tracked';
  }

  @override
  String get episodes => 'Episodes';

  @override
  String get manga => 'Manga / Comic';

  @override
  String get chapters => 'Chapters';

  @override
  String get estimatedVolumes => 'Estimated Volumes';

  @override
  String get volumeRatio => 'Based on 9 Chapters/Volume ratio';

  @override
  String get volumes => 'Volumes';

  @override
  String get statsNote =>
      'Note: Estimated watch time is calculated as 1 episode = 24 minutes.';

  @override
  String get errorLoadData => 'Failed to Load Data';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get errorEmptyData => 'No Data Yet';

  @override
  String get errorPopularData => 'Popular data could not be loaded.';

  @override
  String get noCategory => 'No custom categories yet.';

  @override
  String get addCategory => 'Add Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get categoryName => 'Category Name';

  @override
  String get progressUnit => 'Progress Unit (e.g., Part, Page, Task)';

  @override
  String get save => 'Save';

  @override
  String get deleteCategory => 'Delete Category?';

  @override
  String deleteCategoryDesc(Object name) {
    return 'Deleting category \"$name\" will remove all entries in it. Continue?';
  }

  @override
  String get categoryAdded => 'Category added.';

  @override
  String get categoryUpdated => 'Category updated.';

  @override
  String get categoryDeleted => 'Category deleted.';

  @override
  String get failedAddCategory => 'Failed to add category';

  @override
  String get failedEditCategory => 'Failed to edit category';

  @override
  String get failedDeleteCategory => 'Failed to delete category';

  @override
  String get deviceIdNotAvailable => 'Device ID not available.';

  @override
  String idCopied(Object id) {
    return 'ID copied: $id';
  }

  @override
  String get sourceData => 'Catalog Data Source';

  @override
  String get sourceDataDesc =>
      'Anime & manga data provided by AniList API (GraphQL).';

  @override
  String get storageData => 'Data Storage';

  @override
  String get storageDataDesc =>
      'Personal collection stored securely in Supabase (PostgreSQL).';

  @override
  String get deviceId => 'Device ID';

  @override
  String get loadingId => 'Loading ID...';

  @override
  String get classLabel => 'Class';

  @override
  String get nimLabel => 'NIM';

  @override
  String get supportUs => 'Support Us';

  @override
  String get supportThankYou => 'Thank you for your support!';

  @override
  String get aboutApp => 'About App';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get course => 'Course';

  @override
  String get dataSource => 'Data Source';

  @override
  String get copyright => '© 2026 Tsuzuki App';

  @override
  String get appDescription =>
      'Anime and Comic (Manga, Manhwa, Manhua) progress tracker app.';

  @override
  String get helpFaq => 'Help & FAQ';

  @override
  String get faq1Title => 'How to add anime/comic to collection?';

  @override
  String get faq1Desc =>
      'Open the Catalog tab, search for the desired title, then tap the card. On the detail page, press the \"Add to Collection\" button.';

  @override
  String get faq2Title => 'What is the +1 button on the collection card?';

  @override
  String get faq2Desc =>
      'The +1 button quickly adds progress (episode/chapter) without opening the edit page. If progress reaches the total, status automatically becomes \"Completed\".';

  @override
  String get faq3Title => 'Why can\'t I modify data when offline?';

  @override
  String get faq3Desc =>
      'When offline, the app displays cached data to prevent data conflicts. Add, Edit, and Delete operations require an internet connection to the database.';

  @override
  String get faq4Title => 'How to change app theme?';

  @override
  String get faq4Desc =>
      'Open the Others tab, then select \"App Theme\". You can choose Dark, Light, or follow system mode.';

  @override
  String get statusPlanned => 'Planned';

  @override
  String get statusOngoing => 'Ongoing';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusDropped => 'Dropped';

  @override
  String get note => 'Note';

  @override
  String get editEntry => 'Edit This Entry';

  @override
  String get noNotes => 'No notes.';

  @override
  String get favoriteTitle => 'My Favorites';

  @override
  String get statAnime => 'Anime';

  @override
  String get statManga => 'Manga';

  @override
  String get statDaysWatched => 'Days Watched';

  @override
  String get statEpisodes => 'Episodes';

  @override
  String get statChapters => 'Chapters Read';

  @override
  String get statVolumes => 'Volumes Read';

  @override
  String get logoutConfirmDesc =>
      'Are you sure you want to log out of this account?';

  @override
  String get logoutConfirmBtn => 'Logout';

  @override
  String get logoutFailed => 'Failed to log out, try again.';

  @override
  String get emptyCollectionPrompt => 'Start adding your first anime!';

  @override
  String joinedAt(Object date) {
    return 'Joined on $date';
  }

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String get greetingSubtitle => 'Let\'s continue your progress today.';

  @override
  String get claimTitle => 'Move old data?';

  @override
  String claimDesc(Object count, Object username) {
    return 'Found $count old collections on this device not linked to your account. Move to @$username?';
  }

  @override
  String get claimBtn => 'Move';

  @override
  String claimSuccess(Object count) {
    return '$count collections moved successfully.';
  }

  @override
  String get claimFailed => 'Failed to move old data.';

  @override
  String get offlineBanner => 'Offline Mode: Data may not be up to date.';

  @override
  String get progressAdded => 'Progress +1 successful.';

  @override
  String get congratsCompleted => 'Congratulations! You completed this title.';
}
