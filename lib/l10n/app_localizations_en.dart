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
  String get onboardingSlide2Title => 'Track Your Progress';

  @override
  String get onboardingSlide2Desc =>
      'Easily log episodes or chapters you have watched and read.';

  @override
  String get onboardingSlide3Title => 'Personal Collection';

  @override
  String get onboardingSlide3Desc =>
      'Save your favorite titles, give ratings, and add personal notes.';

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
  String get categoryUnitPrefix => 'Unit:';

  @override
  String get save => 'Save';

  @override
  String get deleteCategory => 'Delete Category?';

  @override
  String get deleteCategoryDesc =>
      'Entries in this category will become uncategorized.';

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
  String get categoryGenericError => 'An error occurred.';

  @override
  String get categoryDeleteFailed => 'Failed to delete.';

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
  String get statusOngoingWatch => 'Watching';

  @override
  String get statusOngoingRead => 'Reading';

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

  @override
  String get logoutTitle => 'Log Out?';

  @override
  String greeting(Object name) {
    return 'Hello, $name! 👋';
  }

  @override
  String totalWatchTime(Object hours) {
    return '$hours Hours';
  }

  @override
  String totalWatchTimeMinutes(Object minutes) {
    return '$minutes Minutes';
  }

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get noData => 'No data yet';

  @override
  String animeLegend(Object percent) {
    return 'Anime $percent%';
  }

  @override
  String mangaLegend(Object percent) {
    return 'Manga $percent%';
  }

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Enthusiast';

  @override
  String get levelVeteran => 'Veteran';

  @override
  String showingResults(Object count, Object total) {
    return 'Showing $count of $total';
  }

  @override
  String get loadMoreFailed => 'Failed to load. Tap to retry.';

  @override
  String get filterGenre => 'Genre';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterYear => 'Year';

  @override
  String get filterScore => 'Minimum Score';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortPopular => 'Popular';

  @override
  String get sortScore => 'Highest Score';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortTitle => 'A-Z';

  @override
  String get statusAiring => 'Airing';

  @override
  String get statusFinished => 'Finished';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get all => 'All';

  @override
  String get filterType => 'Type';

  @override
  String get onlyFavorites => 'Only Favorites';

  @override
  String get sortProgress => 'Highest Progress';

  @override
  String get sortRating => 'Highest Rating';

  @override
  String get favoriteAdded => 'Added to favorites.';

  @override
  String get favoriteRemoved => 'Removed from favorites.';

  @override
  String get entryDeleted => 'Deleted from collection.';

  @override
  String get inCollection => 'In Collection';

  @override
  String get progressRemoved => 'Progress -1 successful.';

  @override
  String get exportTitle => 'Export Collection';

  @override
  String get exportDesc => 'Save your collection to a JSON file.';

  @override
  String get importTitle => 'Import Collection';

  @override
  String get importDesc => 'Restore your collection from a backup file.';

  @override
  String get importMerge => 'Merge';

  @override
  String get importReplace => 'Replace All';

  @override
  String get importMergeDesc => 'Add new titles, skip duplicates.';

  @override
  String get importReplaceDesc =>
      'Delete all current titles and replace with the backup.';

  @override
  String get confirmDeleteAll => 'Type DELETE ALL to confirm';

  @override
  String get confirmDeleteAllHint => 'DELETE ALL';

  @override
  String get deleteAllTitle => 'Delete all collections?';

  @override
  String get deleteAllDesc =>
      'This will permanently remove all your saved titles. This action cannot be undone.';

  @override
  String get retryConnection => 'Retry Connection';

  @override
  String get stillOffline => 'Still offline. Check your connection.';

  @override
  String get duplicateTitleWarning =>
      'This title already exists in your collection. Add anyway?';

  @override
  String get addAnyway => 'Add Anyway';

  @override
  String get entryAdded => 'Added to collection.';

  @override
  String get entryUpdated => 'Entry updated.';

  @override
  String get openCollection => 'Open Collection';

  @override
  String get viewOriginal => 'View Original Text';

  @override
  String get viewTranslation => 'View Translation';

  @override
  String get unsavedChangesTitle => 'Discard changes?';

  @override
  String get unsavedChangesDesc =>
      'You have unsaved changes. Are you sure you want to leave?';

  @override
  String get discard => 'Discard';

  @override
  String get imageCache => 'Image Cache';

  @override
  String get keepEditing => 'Keep Editing';

  @override
  String get confirmPasswordHint => 'Confirm new password';

  @override
  String get confirmPasswordMismatch => 'Passwords do not match.';

  @override
  String get profileSavedPasswordFailed =>
      'Profile updated, but password change failed.';

  @override
  String get profilePasswordSaved => 'Profile and password updated.';

  @override
  String get passwordOnlySaved => 'Password updated.';

  @override
  String get noPasswordRecovery =>
      'Note: This app uses a username-based login. If you forget your password, you may lose access to your account. We recommend using Backup & Restore to save a copy of your collection.';

  @override
  String get passwordRecoveryFaqTitle => 'I forgot my password. What can I do?';

  @override
  String get passwordRecoveryFaqDesc =>
      'This app uses username-only login without email recovery. If you forget your password, the account cannot be recovered. Always use Backup & Restore regularly to keep a safe copy of your collection.';

  @override
  String get loginFailedTitle => 'Login failed';

  @override
  String get registerFailedTitle => 'Registration failed';

  @override
  String get networkErrorTitle => 'Connection problem';

  @override
  String get networkErrorDesc =>
      'Please check your internet connection and try again.';

  @override
  String get timeoutErrorDesc =>
      'The server took too long to respond. Try again.';

  @override
  String get statusSuggestCompleted => 'Mark as Completed?';

  @override
  String get statusSuggestCompletedDesc =>
      'Progress has reached the total. Update status to Completed?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get registerButton => 'Register';

  @override
  String get processing => 'Processing...';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get loginHeader => 'Log In to Tsuzuki';

  @override
  String get loginSubtitle => 'Continue tracking your anime and comics.';

  @override
  String get noAccountYet => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get registerHeader => 'Create Tsuzuki Account';

  @override
  String get registerSubtitle =>
      'Your collection will be saved to your account and accessible from other devices.';

  @override
  String get registerTerms =>
      'By registering, you agree that your collection data is stored securely and only accessible by your account.';

  @override
  String get usernameHint => '3–20 characters: letters, numbers, underscore.';

  @override
  String get passwordHint => 'At least 6 characters.';

  @override
  String get usernameRequired => 'Username is required.';

  @override
  String get usernameMinLength => 'Username must be at least 3 characters.';

  @override
  String get usernameMaxLength => 'Username can be at most 20 characters.';

  @override
  String get usernameInvalidChars =>
      'Only letters, numbers, and underscore allowed.';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters.';

  @override
  String get confirmPasswordRequired => 'Password confirmation is required.';

  @override
  String get confirmPasswordNotMatch => 'Passwords do not match.';

  @override
  String get displayNameLabel => 'Display Name';

  @override
  String get displayNameEmpty => 'Name cannot be empty';

  @override
  String get displayNameMaxLength => 'Maximum 30 characters';

  @override
  String get newPasswordLabel => 'New Password (Optional)';

  @override
  String get newPasswordHint => 'Leave blank to keep current password';

  @override
  String get chooseAvatar => 'Choose Avatar';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated successfully!';

  @override
  String get backupTitlesEmpty => 'Collection is empty, nothing to export.';

  @override
  String get backupFileInvalid => 'File is not valid JSON.';

  @override
  String get backupFormatInvalid =>
      'Invalid file format. Must be a JSON array or an object containing an items list.';

  @override
  String get backupEmpty => 'File is empty, no data to import.';

  @override
  String backupEntryInvalid(Object n) {
    return 'Entry #$n: invalid format.';
  }

  @override
  String backupEntryMissing(Object field, Object n) {
    return 'Entry #$n: \"$field\" is required.';
  }

  @override
  String backupEntryReadFail(Object n) {
    return 'Entry #$n: failed to read.';
  }

  @override
  String get storageCacheImages => 'Image Cache';

  @override
  String get storageCacheCollection => 'Collection Data';

  @override
  String get storageCacheTranslation => 'Translation Cache';

  @override
  String get storageClearSuccess => 'Cache cleared.';

  @override
  String get fieldStatus => 'Status';

  @override
  String fieldProgressUnit(Object unit) {
    return 'Progress ($unit)';
  }

  @override
  String get fieldTotal => 'Total';

  @override
  String get fieldRating => 'Rating (Optional)';

  @override
  String get fieldNote => 'Note (Optional)';

  @override
  String get fieldRequired => 'Required';

  @override
  String get fieldMustBeNumber => 'Must be a number';

  @override
  String get fieldNotNegative => 'Cannot be negative';

  @override
  String get fieldExceedsTotal => 'Exceeds total';

  @override
  String get noFavoritesTitle => 'No Favorites Yet';

  @override
  String get noFavoritesDesc =>
      'Mark your favorite anime or comics with the heart icon.';

  @override
  String get favoritesMarkHint => 'Favorited';

  @override
  String get gridView => 'Grid View';

  @override
  String get listView => 'List View';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get reconnected => 'Connection restored.';

  @override
  String get nsfwSettingsTitle => 'NSFW Content (18+)';

  @override
  String get nsfwSettingsSubtitle =>
      'Show adult content in the catalog. Default: off.';

  @override
  String get nsfwEnableTitle => 'Enable 18+ Content?';

  @override
  String get nsfwEnableBody =>
      'By enabling, you declare that you are 18 years or older and willing to view adult content. This content is only shown in the catalog.';

  @override
  String get refresh => 'Refresh';

  @override
  String imageCacheLimitLabel(Object size) {
    return 'Image cache limit: $size';
  }

  @override
  String get confirmClearCacheTitle => 'Clear cache?';

  @override
  String get confirmClearCacheBody =>
      'Cache will be cleared. Data on the server is not affected.';

  @override
  String get typeOther => 'Other';

  @override
  String preImportBackupSaved(Object filename) {
    return 'Previous backup saved: $filename';
  }

  @override
  String get imageCacheDesc =>
      'Limit image cache to a maximum of 100MB. When disabled, the cache is unlimited.';

  @override
  String get sortAddedDate => 'Date Added';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get sortDirection => 'Direction';

  @override
  String get selectItems => 'Select';

  @override
  String selectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get changeLabel => 'Change Label';

  @override
  String get changeStatus => 'Change Status';

  @override
  String get removeLabel => 'Remove Label';

  @override
  String get noLabel => 'No Label';

  @override
  String confirmDeleteMultiple(Object count) {
    return 'Delete $count selected items?';
  }

  @override
  String get confirmDeleteMultipleDesc =>
      'This action will permanently remove the selected titles from your collection.';

  @override
  String bulkDeleted(Object count) {
    return '$count items deleted.';
  }

  @override
  String bulkUpdated(Object count) {
    return '$count items updated.';
  }

  @override
  String get comic => 'Comic';

  @override
  String get sortPickOrder => 'Sort by';

  @override
  String showingResultsPartial(Object count, Object total) {
    return 'Showing $count of $total · scroll to load more';
  }

  @override
  String get cardSizeTitle => 'Card Size';

  @override
  String get cardSizeSubtitle => 'Adjust the size of media cards';

  @override
  String get cardSizeSmall => 'Small';

  @override
  String get cardSizeMedium => 'Medium';

  @override
  String get cardSizeLarge => 'Large';

  @override
  String get copy => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get displayMode => 'Display';

  @override
  String get displayGrid => 'Grid';

  @override
  String get displayList => 'List';

  @override
  String get displayCardSize => 'Card size';

  @override
  String get itemsPerRow => 'Items per row';

  @override
  String get alternativeTitles => 'Alternative Titles';

  @override
  String get randomPick => 'Random';

  @override
  String get debugInfo => 'Debug Info';

  @override
  String get helpSearchHint => 'Search help...';

  @override
  String get helpNoResults => 'No results found for your search.';

  @override
  String get helpCatGettingStarted => 'Getting Started';

  @override
  String get helpCatCatalog => 'Catalog & Search';

  @override
  String get helpCatCollection => 'Collection & Progress';

  @override
  String get helpCatSettings => 'Settings & Display';

  @override
  String get helpCatData => 'Data & Backup';

  @override
  String get helpCatTroubleshooting => 'Troubleshooting';

  @override
  String get faq5Title => 'How do I change the card size or layout?';

  @override
  String get faq5Desc =>
      'Open the Catalog or Collection tab, tap the \'Layout\' icon (view_quilt) in the top right, then choose Grid or List, select a card size (Small/Medium/Large), or slide \'Items per row\' (2-6). Changes apply instantly.';

  @override
  String get faq6Title => 'How do I add a custom colored label?';

  @override
  String get faq6Desc =>
      'Go to Others → Manage Labels. Tap the + button, enter a name, choose a color from the palette, and save. When adding or editing a collection, you can assign this label. The color will appear in your collection cards.';

  @override
  String get faq7Title => 'What is the Random Pick (shuffle) button?';

  @override
  String get faq7Desc =>
      'In the Catalog tab, tap the shuffle icon in the top bar. It randomly opens the detail page of one of the currently loaded titles. Useful when you\'re indecisive about what to watch or read.';

  @override
  String get faq8Title => 'How do I backup or restore my collection?';

  @override
  String get faq8Desc =>
      'Go to Others → Settings → Backup & Restore. Tap \'Export\' to save your collection as a JSON file (share to Drive/Files). Tap \'Import\' to restore from a file. You can choose to Merge (add new titles) or Replace All (delete current and replace).';

  @override
  String get faq9Title => 'Why do my changes fail when offline?';

  @override
  String get faq9Desc =>
      'When offline, the app displays cached data to prevent sync conflicts. Add, Edit, and Delete operations require an internet connection to Supabase. When your connection returns, tap \'Retry Connection\' on the yellow offline banner to sync.';

  @override
  String get faq10Title => 'What is Debug Info and how do I use it?';

  @override
  String get faq10Desc =>
      'Go to Others → Debug Info. This page shows app version, connection status (Supabase & AniList), active settings, and the last error. Tap the copy icon in the top right to copy all info — useful for reporting bugs to the developer.';

  @override
  String get faq11Title => 'How do I enable NSFW (18+) content?';

  @override
  String get faq11Desc =>
      'Go to Others → Settings → toggle \'NSFW Content (18+)\'. You must confirm you are 18+ before enabling. When enabled, the catalog will show 18+ titles with a red \'18+\' badge. This setting only affects the Catalog, not your collection.';

  @override
  String get faq12Title =>
      'How do I filter the catalog by genre, year, or status?';

  @override
  String get faq12Desc =>
      'In the Catalog tab, tap the filter icon in the top bar to open the filter sheet. You can filter by genre, tag, year, status, minimum score, and sort order. From any detail page, you can tap the year/status/genre chips to jump directly to a filtered catalog.';

  @override
  String get faq13Title => 'How do I use bulk actions (delete, label, status)?';

  @override
  String get faq13Desc =>
      'In the Collection tab, tap the checklist icon in the top bar (or long-press an item) to enter selection mode. Select multiple items, then use the bottom bar to Delete, Change Label, or Change Status in bulk.';

  @override
  String get faq14Title => 'How do I mark an item as Favorite?';

  @override
  String get faq14Desc =>
      'Open a collection detail page, then tap the heart icon in the top right. Favorites appear in Profile → My Favorites, where you can filter by Anime or Comic.';

  @override
  String get faq15Title => 'What do the progress validation rules do?';

  @override
  String get faq15Desc =>
      'Progress cannot be negative and cannot exceed the total episode/chapter count. If you set status to \'Completed\', the app will offer to auto-fill progress to the total. If progress reaches the total, the status will auto-update to \'Completed\'.';

  @override
  String get faq16Title => 'How do I change the app theme or language?';

  @override
  String get faq16Desc =>
      'Go to Others → Settings. Under \'App Theme\', choose Dark, Light, or Follow System. Under \'Language\', choose Indonesian or English. Changes apply instantly across the entire app.';

  @override
  String get faq17Title => 'What do the album cover icons mean?';

  @override
  String get faq17Desc =>
      'The colored dot on each media card indicates the media type: Blue for Anime, Red for Manga, Gold for Manhwa, Purple for Manhua. A red \'18+\' badge means the title contains adult content.';

  @override
  String get tagLabel => 'Tag';

  @override
  String get allTags => 'All Tags';

  @override
  String get genreTagInfo =>
      'Genres and Tags are combined (AND). More selections = fewer results.';
}
