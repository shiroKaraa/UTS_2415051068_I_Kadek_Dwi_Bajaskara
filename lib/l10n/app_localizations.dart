import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'Tsuzuki'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCatalog.
  ///
  /// In id, this message translates to:
  /// **'Katalog'**
  String get navCatalog;

  /// No description provided for @navCollection.
  ///
  /// In id, this message translates to:
  /// **'Koleksi'**
  String get navCollection;

  /// No description provided for @navOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get navOther;

  /// No description provided for @navProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @welcome.
  ///
  /// In id, this message translates to:
  /// **'Halo, Selamat Datang!'**
  String get welcome;

  /// No description provided for @subWelcome.
  ///
  /// In id, this message translates to:
  /// **'Terus lacak progres tontonan dan bacaanmu.'**
  String get subWelcome;

  /// No description provided for @continueWatching.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get continueWatching;

  /// No description provided for @popularAnime.
  ///
  /// In id, this message translates to:
  /// **'Anime Populer'**
  String get popularAnime;

  /// No description provided for @popularManga.
  ///
  /// In id, this message translates to:
  /// **'Komik Populer'**
  String get popularManga;

  /// No description provided for @seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get seeAll;

  /// No description provided for @searchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari judul...'**
  String get searchHint;

  /// No description provided for @addToCollection.
  ///
  /// In id, this message translates to:
  /// **'Tambah ke Koleksi'**
  String get addToCollection;

  /// No description provided for @emptyCollection.
  ///
  /// In id, this message translates to:
  /// **'Koleksi Kosong'**
  String get emptyCollection;

  /// No description provided for @emptyCollectionDesc.
  ///
  /// In id, this message translates to:
  /// **'Cari judul di Katalog dan tambahkan yang pertama.'**
  String get emptyCollectionDesc;

  /// No description provided for @statTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get statTotal;

  /// No description provided for @statReading.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get statReading;

  /// No description provided for @statCompleted.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get statCompleted;

  /// No description provided for @noTrackedYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada yang dilacak.'**
  String get noTrackedYet;

  /// No description provided for @searchFirst.
  ///
  /// In id, this message translates to:
  /// **'Cari anime atau komik pertamamu.'**
  String get searchFirst;

  /// No description provided for @searchNow.
  ///
  /// In id, this message translates to:
  /// **'Cari Sekarang'**
  String get searchNow;

  /// No description provided for @progress.
  ///
  /// In id, this message translates to:
  /// **'Progres'**
  String get progress;

  /// No description provided for @onboardingTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang di Tsuzuki'**
  String get onboardingTitle;

  /// No description provided for @onboardingDesc.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi pelacak progres tontonan Anime dan bacaan Komik favoritmu.'**
  String get onboardingDesc;

  /// No description provided for @skip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In id, this message translates to:
  /// **'Mulai Sekarang'**
  String get getStarted;

  /// No description provided for @filterCatalog.
  ///
  /// In id, this message translates to:
  /// **'Filter Katalog'**
  String get filterCatalog;

  /// No description provided for @allGenres.
  ///
  /// In id, this message translates to:
  /// **'Semua Genre'**
  String get allGenres;

  /// No description provided for @allYears.
  ///
  /// In id, this message translates to:
  /// **'Semua Tahun'**
  String get allYears;

  /// No description provided for @reset.
  ///
  /// In id, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get apply;

  /// No description provided for @searchInCollection.
  ///
  /// In id, this message translates to:
  /// **'Cari di koleksimu...'**
  String get searchInCollection;

  /// No description provided for @activeFilter.
  ///
  /// In id, this message translates to:
  /// **'Filter Aktif'**
  String get activeFilter;

  /// No description provided for @clearAll.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua'**
  String get clearAll;

  /// No description provided for @offlineMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Offline: Menampilkan data tersimpan.'**
  String get offlineMode;

  /// No description provided for @noResults.
  ///
  /// In id, this message translates to:
  /// **'Tidak Ada Hasil'**
  String get noResults;

  /// No description provided for @noResultsDesc.
  ///
  /// In id, this message translates to:
  /// **'Coba ubah kata kunci atau filter pencarianmu.'**
  String get noResultsDesc;

  /// No description provided for @resetFilter.
  ///
  /// In id, this message translates to:
  /// **'Reset Filter'**
  String get resetFilter;

  /// No description provided for @synopsis.
  ///
  /// In id, this message translates to:
  /// **'Sinopsis'**
  String get synopsis;

  /// No description provided for @noSynopsis.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada sinopsis.'**
  String get noSynopsis;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @undo.
  ///
  /// In id, this message translates to:
  /// **'Urungkan'**
  String get undo;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In id, this message translates to:
  /// **'Tema Aplikasi'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In id, this message translates to:
  /// **'Ikuti Sistem'**
  String get system;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa / Language'**
  String get language;

  /// No description provided for @backupRestore.
  ///
  /// In id, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @backupDesc.
  ///
  /// In id, this message translates to:
  /// **'Ekspor atau impor koleksi Anda'**
  String get backupDesc;

  /// No description provided for @manageCategories.
  ///
  /// In id, this message translates to:
  /// **'Kelola Kategori'**
  String get manageCategories;

  /// No description provided for @statistics.
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get statistics;

  /// No description provided for @storage.
  ///
  /// In id, this message translates to:
  /// **'Data dan penyimpanan'**
  String get storage;

  /// No description provided for @about.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get about;

  /// No description provided for @help.
  ///
  /// In id, this message translates to:
  /// **'Bantuan'**
  String get help;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @totalTitles.
  ///
  /// In id, this message translates to:
  /// **'Total Judul'**
  String get totalTitles;

  /// No description provided for @completed.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get completed;

  /// No description provided for @estimatedTime.
  ///
  /// In id, this message translates to:
  /// **'Estimasi Waktu Menonton'**
  String get estimatedTime;

  /// No description provided for @days.
  ///
  /// In id, this message translates to:
  /// **'Hari'**
  String get days;

  /// No description provided for @activityDetails.
  ///
  /// In id, this message translates to:
  /// **'Rincian Aktivitas'**
  String get activityDetails;

  /// No description provided for @anime.
  ///
  /// In id, this message translates to:
  /// **'Anime'**
  String get anime;

  /// No description provided for @trackedTitles.
  ///
  /// In id, this message translates to:
  /// **'{count} Judul dilacak'**
  String trackedTitles(Object count);

  /// No description provided for @episodes.
  ///
  /// In id, this message translates to:
  /// **'Episode'**
  String get episodes;

  /// No description provided for @manga.
  ///
  /// In id, this message translates to:
  /// **'Manga / Komik'**
  String get manga;

  /// No description provided for @chapters.
  ///
  /// In id, this message translates to:
  /// **'Chapter'**
  String get chapters;

  /// No description provided for @estimatedVolumes.
  ///
  /// In id, this message translates to:
  /// **'Estimasi Volume'**
  String get estimatedVolumes;

  /// No description provided for @volumeRatio.
  ///
  /// In id, this message translates to:
  /// **'Berdasarkan rasio 9 Chapter/Volume'**
  String get volumeRatio;

  /// No description provided for @volumes.
  ///
  /// In id, this message translates to:
  /// **'Volume'**
  String get volumes;

  /// No description provided for @statsNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan: Estimasi waktu menonton dihitung dari 1 episode = 24 menit.'**
  String get statsNote;

  /// No description provided for @errorLoadData.
  ///
  /// In id, this message translates to:
  /// **'Gagal Memuat Data'**
  String get errorLoadData;

  /// No description provided for @tryAgain.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get tryAgain;

  /// No description provided for @errorEmptyData.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Data'**
  String get errorEmptyData;

  /// No description provided for @errorPopularData.
  ///
  /// In id, this message translates to:
  /// **'Data populer tidak dapat dimuat.'**
  String get errorPopularData;

  /// No description provided for @noCategory.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori kustom.'**
  String get noCategory;

  /// No description provided for @addCategory.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kategori'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In id, this message translates to:
  /// **'Edit Kategori'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In id, this message translates to:
  /// **'Nama Kategori'**
  String get categoryName;

  /// No description provided for @progressUnit.
  ///
  /// In id, this message translates to:
  /// **'Satuan Progres (misal: Bagian, Halaman, Tugas)'**
  String get progressUnit;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @deleteCategory.
  ///
  /// In id, this message translates to:
  /// **'Hapus Kategori?'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryDesc.
  ///
  /// In id, this message translates to:
  /// **'Menghapus kategori \"{name}\" akan menghapus semua entri di dalamnya. Lanjutkan?'**
  String deleteCategoryDesc(Object name);

  /// No description provided for @categoryAdded.
  ///
  /// In id, this message translates to:
  /// **'Kategori ditambahkan.'**
  String get categoryAdded;

  /// No description provided for @categoryUpdated.
  ///
  /// In id, this message translates to:
  /// **'Kategori diperbarui.'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In id, this message translates to:
  /// **'Kategori dihapus.'**
  String get categoryDeleted;

  /// No description provided for @failedAddCategory.
  ///
  /// In id, this message translates to:
  /// **'Gagal menambah kategori'**
  String get failedAddCategory;

  /// No description provided for @failedEditCategory.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengedit kategori'**
  String get failedEditCategory;

  /// No description provided for @failedDeleteCategory.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus kategori'**
  String get failedDeleteCategory;

  /// No description provided for @deviceIdNotAvailable.
  ///
  /// In id, this message translates to:
  /// **'ID Perangkat belum tersedia.'**
  String get deviceIdNotAvailable;

  /// No description provided for @idCopied.
  ///
  /// In id, this message translates to:
  /// **'ID disalin: {id}'**
  String idCopied(Object id);

  /// No description provided for @sourceData.
  ///
  /// In id, this message translates to:
  /// **'Sumber Data Katalog'**
  String get sourceData;

  /// No description provided for @sourceDataDesc.
  ///
  /// In id, this message translates to:
  /// **'Data anime & manga disediakan oleh AniList API (GraphQL).'**
  String get sourceDataDesc;

  /// No description provided for @storageData.
  ///
  /// In id, this message translates to:
  /// **'Penyimpanan Data'**
  String get storageData;

  /// No description provided for @storageDataDesc.
  ///
  /// In id, this message translates to:
  /// **'Koleksi pribadi disimpan dengan aman di Supabase (PostgreSQL).'**
  String get storageDataDesc;

  /// No description provided for @deviceId.
  ///
  /// In id, this message translates to:
  /// **'ID Perangkat'**
  String get deviceId;

  /// No description provided for @loadingId.
  ///
  /// In id, this message translates to:
  /// **'Memuat ID...'**
  String get loadingId;

  /// No description provided for @classLabel.
  ///
  /// In id, this message translates to:
  /// **'Kelas'**
  String get classLabel;

  /// No description provided for @nimLabel.
  ///
  /// In id, this message translates to:
  /// **'NIM'**
  String get nimLabel;

  /// No description provided for @supportUs.
  ///
  /// In id, this message translates to:
  /// **'Dukung Kami'**
  String get supportUs;

  /// No description provided for @supportThankYou.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih atas dukungan Anda!'**
  String get supportThankYou;

  /// No description provided for @aboutApp.
  ///
  /// In id, this message translates to:
  /// **'Tentang Aplikasi'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In id, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @course.
  ///
  /// In id, this message translates to:
  /// **'Mata Kuliah'**
  String get course;

  /// No description provided for @dataSource.
  ///
  /// In id, this message translates to:
  /// **'Sumber Data'**
  String get dataSource;

  /// No description provided for @copyright.
  ///
  /// In id, this message translates to:
  /// **'© 2026 Tsuzuki App'**
  String get copyright;

  /// No description provided for @appDescription.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi pelacak progres tontonan Anime dan bacaan Komik (Manga, Manhwa, Manhua).'**
  String get appDescription;

  /// No description provided for @helpFaq.
  ///
  /// In id, this message translates to:
  /// **'Bantuan & FAQ'**
  String get helpFaq;

  /// No description provided for @faq1Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara menambahkan anime/komik ke koleksi?'**
  String get faq1Title;

  /// No description provided for @faq1Desc.
  ///
  /// In id, this message translates to:
  /// **'Buka tab Katalog, cari judul yang diinginkan, lalu tekan kartu tersebut. Di halaman detail, tekan tombol \"Tambah ke Koleksi\".'**
  String get faq1Desc;

  /// No description provided for @faq2Title.
  ///
  /// In id, this message translates to:
  /// **'Apa fungsi tombol +1 pada kartu koleksi?'**
  String get faq2Title;

  /// No description provided for @faq2Desc.
  ///
  /// In id, this message translates to:
  /// **'Tombol +1 berfungsi untuk menambah progres (episode/chapter) dengan cepat tanpa harus membuka halaman edit. Jika progres mencapai total, status otomatis menjadi \"Selesai\".'**
  String get faq2Desc;

  /// No description provided for @faq3Title.
  ///
  /// In id, this message translates to:
  /// **'Mengapa data saya tidak bisa diubah saat offline?'**
  String get faq3Title;

  /// No description provided for @faq3Desc.
  ///
  /// In id, this message translates to:
  /// **'Saat offline, aplikasi menampilkan data cache untuk mencegah konflik data. Operasi Tambah, Edit, dan Hapus memerlukan koneksi internet ke database.'**
  String get faq3Desc;

  /// No description provided for @faq4Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara mengubah tema aplikasi?'**
  String get faq4Title;

  /// No description provided for @faq4Desc.
  ///
  /// In id, this message translates to:
  /// **'Buka tab Lainnya, lalu pilih menu \"Tema Aplikasi\". Anda dapat memilih mode Gelap, Terang, atau mengikuti sistem.'**
  String get faq4Desc;

  /// No description provided for @statusPlanned.
  ///
  /// In id, this message translates to:
  /// **'Direncanakan'**
  String get statusPlanned;

  /// No description provided for @statusOngoing.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get statusOngoing;

  /// No description provided for @statusCompleted.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get statusCompleted;

  /// No description provided for @statusPaused.
  ///
  /// In id, this message translates to:
  /// **'Ditunda'**
  String get statusPaused;

  /// No description provided for @statusDropped.
  ///
  /// In id, this message translates to:
  /// **'Dihentikan'**
  String get statusDropped;

  /// No description provided for @note.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get note;

  /// No description provided for @editEntry.
  ///
  /// In id, this message translates to:
  /// **'Edit Entri Ini'**
  String get editEntry;

  /// No description provided for @noNotes.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada catatan.'**
  String get noNotes;

  /// No description provided for @favoriteTitle.
  ///
  /// In id, this message translates to:
  /// **'Favorit Saya'**
  String get favoriteTitle;

  /// No description provided for @statAnime.
  ///
  /// In id, this message translates to:
  /// **'Anime'**
  String get statAnime;

  /// No description provided for @statManga.
  ///
  /// In id, this message translates to:
  /// **'Manga'**
  String get statManga;

  /// No description provided for @statDaysWatched.
  ///
  /// In id, this message translates to:
  /// **'Hari Ditonton'**
  String get statDaysWatched;

  /// No description provided for @statEpisodes.
  ///
  /// In id, this message translates to:
  /// **'Episode'**
  String get statEpisodes;

  /// No description provided for @statChapters.
  ///
  /// In id, this message translates to:
  /// **'Chapter'**
  String get statChapters;

  /// No description provided for @statVolumes.
  ///
  /// In id, this message translates to:
  /// **'Volume'**
  String get statVolumes;

  /// No description provided for @logoutConfirmDesc.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin keluar dari akun ini?'**
  String get logoutConfirmDesc;

  /// No description provided for @logoutConfirmBtn.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logoutConfirmBtn;

  /// No description provided for @logoutFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal keluar, coba lagi.'**
  String get logoutFailed;

  /// No description provided for @emptyCollectionPrompt.
  ///
  /// In id, this message translates to:
  /// **'Mulai tambahkan anime pertamamu!'**
  String get emptyCollectionPrompt;

  /// No description provided for @joinedAt.
  ///
  /// In id, this message translates to:
  /// **'Bergabung sejak {date}'**
  String joinedAt(Object date);

  /// No description provided for @greetingMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat Pagi'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat Siang'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In id, this message translates to:
  /// **'Selamat Malam'**
  String get greetingEvening;

  /// No description provided for @greetingSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Mari lanjutkan progresmu hari ini.'**
  String get greetingSubtitle;

  /// No description provided for @claimTitle.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan data lama?'**
  String get claimTitle;

  /// No description provided for @claimDesc.
  ///
  /// In id, this message translates to:
  /// **'Ditemukan {count} koleksi lama di perangkat ini yang belum terhubung ke akun. Pindahkan ke akun @{username}?'**
  String claimDesc(Object count, Object username);

  /// No description provided for @claimBtn.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan'**
  String get claimBtn;

  /// No description provided for @claimSuccess.
  ///
  /// In id, this message translates to:
  /// **'{count} koleksi berhasil dipindahkan.'**
  String claimSuccess(Object count);

  /// No description provided for @claimFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memindahkan data lama.'**
  String get claimFailed;

  /// No description provided for @offlineBanner.
  ///
  /// In id, this message translates to:
  /// **'Mode Offline: Data mungkin tidak terbaru.'**
  String get offlineBanner;

  /// No description provided for @progressAdded.
  ///
  /// In id, this message translates to:
  /// **'Progres +1 berhasil.'**
  String get progressAdded;

  /// No description provided for @congratsCompleted.
  ///
  /// In id, this message translates to:
  /// **'Selamat! Kamu telah menamatkan judul ini.'**
  String get congratsCompleted;

  /// No description provided for @logoutTitle.
  ///
  /// In id, this message translates to:
  /// **'Keluar Akun?'**
  String get logoutTitle;

  /// No description provided for @greeting.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}! 👋'**
  String greeting(Object name);

  /// No description provided for @totalWatchTime.
  ///
  /// In id, this message translates to:
  /// **'{hours} Jam'**
  String totalWatchTime(Object hours);

  /// No description provided for @totalWatchTimeMinutes.
  ///
  /// In id, this message translates to:
  /// **'{minutes} Menit'**
  String totalWatchTimeMinutes(Object minutes);

  /// No description provided for @editProfile.
  ///
  /// In id, this message translates to:
  /// **'Edit Profil'**
  String get editProfile;

  /// No description provided for @noData.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data'**
  String get noData;

  /// No description provided for @animeLegend.
  ///
  /// In id, this message translates to:
  /// **'Anime {percent}%'**
  String animeLegend(Object percent);

  /// No description provided for @mangaLegend.
  ///
  /// In id, this message translates to:
  /// **'Manga {percent}%'**
  String mangaLegend(Object percent);

  /// No description provided for @levelBeginner.
  ///
  /// In id, this message translates to:
  /// **'Pemula'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In id, this message translates to:
  /// **'Penikmat'**
  String get levelIntermediate;

  /// No description provided for @levelVeteran.
  ///
  /// In id, this message translates to:
  /// **'Veteran'**
  String get levelVeteran;

  /// No description provided for @showingResults.
  ///
  /// In id, this message translates to:
  /// **'Menampilkan {count} dari {total}'**
  String showingResults(Object count, Object total);

  /// No description provided for @loadMoreFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat. Ketuk untuk coba lagi.'**
  String get loadMoreFailed;

  /// No description provided for @filterGenre.
  ///
  /// In id, this message translates to:
  /// **'Genre'**
  String get filterGenre;

  /// No description provided for @filterStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// No description provided for @filterYear.
  ///
  /// In id, this message translates to:
  /// **'Tahun'**
  String get filterYear;

  /// No description provided for @sortBy.
  ///
  /// In id, this message translates to:
  /// **'Urutkan'**
  String get sortBy;

  /// No description provided for @sortPopular.
  ///
  /// In id, this message translates to:
  /// **'Populer'**
  String get sortPopular;

  /// No description provided for @sortScore.
  ///
  /// In id, this message translates to:
  /// **'Skor Tertinggi'**
  String get sortScore;

  /// No description provided for @sortNewest.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get sortNewest;

  /// No description provided for @sortTitle.
  ///
  /// In id, this message translates to:
  /// **'A-Z'**
  String get sortTitle;

  /// No description provided for @statusAiring.
  ///
  /// In id, this message translates to:
  /// **'Sedang Tayang'**
  String get statusAiring;

  /// No description provided for @statusFinished.
  ///
  /// In id, this message translates to:
  /// **'Tamat'**
  String get statusFinished;

  /// No description provided for @statusUpcoming.
  ///
  /// In id, this message translates to:
  /// **'Akan Datang'**
  String get statusUpcoming;

  /// No description provided for @all.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get all;

  /// No description provided for @filterType.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get filterType;

  /// No description provided for @onlyFavorites.
  ///
  /// In id, this message translates to:
  /// **'Hanya Favorit'**
  String get onlyFavorites;

  /// No description provided for @sortProgress.
  ///
  /// In id, this message translates to:
  /// **'Progres Tertinggi'**
  String get sortProgress;

  /// No description provided for @sortRating.
  ///
  /// In id, this message translates to:
  /// **'Rating Tertinggi'**
  String get sortRating;

  /// No description provided for @favoriteAdded.
  ///
  /// In id, this message translates to:
  /// **'Ditambahkan ke favorit.'**
  String get favoriteAdded;

  /// No description provided for @favoriteRemoved.
  ///
  /// In id, this message translates to:
  /// **'Dihapus dari favorit.'**
  String get favoriteRemoved;

  /// No description provided for @entryDeleted.
  ///
  /// In id, this message translates to:
  /// **'Dihapus dari koleksi.'**
  String get entryDeleted;

  /// No description provided for @inCollection.
  ///
  /// In id, this message translates to:
  /// **'Di Koleksi'**
  String get inCollection;

  /// No description provided for @progressRemoved.
  ///
  /// In id, this message translates to:
  /// **'Progres -1 berhasil.'**
  String get progressRemoved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
