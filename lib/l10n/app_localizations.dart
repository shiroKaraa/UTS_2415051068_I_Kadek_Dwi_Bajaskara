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

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In id, this message translates to:
  /// **'Lacak Progresmu'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Desc.
  ///
  /// In id, this message translates to:
  /// **'Catat episode atau chapter yang sudah kamu tonton dan baca dengan mudah.'**
  String get onboardingSlide2Desc;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In id, this message translates to:
  /// **'Koleksi Pribadi'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Desc.
  ///
  /// In id, this message translates to:
  /// **'Simpan judul favoritmu, beri rating, dan buat catatan pribadi.'**
  String get onboardingSlide3Desc;

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
  /// **'Kelola Label'**
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
  /// **'Belum ada Label kustom.'**
  String get noCategory;

  /// No description provided for @addCategory.
  ///
  /// In id, this message translates to:
  /// **'Tambah Label'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In id, this message translates to:
  /// **'Edit Label'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In id, this message translates to:
  /// **'Nama Label'**
  String get categoryName;

  /// No description provided for @progressUnit.
  ///
  /// In id, this message translates to:
  /// **'Satuan Progres (misal: Bagian, Halaman, Tugas)'**
  String get progressUnit;

  /// No description provided for @categoryUnitPrefix.
  ///
  /// In id, this message translates to:
  /// **'Satuan:'**
  String get categoryUnitPrefix;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @deleteCategory.
  ///
  /// In id, this message translates to:
  /// **'Hapus Label?'**
  String get deleteCategory;

  /// No description provided for @deleteCategoryDesc.
  ///
  /// In id, this message translates to:
  /// **'Entri di Label ini akan menjadi tanpa Label.'**
  String get deleteCategoryDesc;

  /// No description provided for @categoryAdded.
  ///
  /// In id, this message translates to:
  /// **'Label ditambahkan.'**
  String get categoryAdded;

  /// No description provided for @categoryUpdated.
  ///
  /// In id, this message translates to:
  /// **'Label diperbarui.'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In id, this message translates to:
  /// **'Label dihapus.'**
  String get categoryDeleted;

  /// No description provided for @failedAddCategory.
  ///
  /// In id, this message translates to:
  /// **'Gagal menambah Label'**
  String get failedAddCategory;

  /// No description provided for @failedEditCategory.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengedit Label'**
  String get failedEditCategory;

  /// No description provided for @failedDeleteCategory.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus Label'**
  String get failedDeleteCategory;

  /// No description provided for @categoryGenericError.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan.'**
  String get categoryGenericError;

  /// No description provided for @categoryDeleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus.'**
  String get categoryDeleteFailed;

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

  /// No description provided for @statusOngoingWatch.
  ///
  /// In id, this message translates to:
  /// **'Sedang Menonton'**
  String get statusOngoingWatch;

  /// No description provided for @statusOngoingRead.
  ///
  /// In id, this message translates to:
  /// **'Sedang Membaca'**
  String get statusOngoingRead;

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

  /// No description provided for @filterScore.
  ///
  /// In id, this message translates to:
  /// **'Skor Minimum'**
  String get filterScore;

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

  /// No description provided for @exportTitle.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Koleksi'**
  String get exportTitle;

  /// No description provided for @exportDesc.
  ///
  /// In id, this message translates to:
  /// **'Simpan koleksi Anda ke file JSON.'**
  String get exportDesc;

  /// No description provided for @importTitle.
  ///
  /// In id, this message translates to:
  /// **'Impor Koleksi'**
  String get importTitle;

  /// No description provided for @importDesc.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan koleksi Anda dari file backup.'**
  String get importDesc;

  /// No description provided for @importMerge.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan'**
  String get importMerge;

  /// No description provided for @importReplace.
  ///
  /// In id, this message translates to:
  /// **'Ganti Semua'**
  String get importReplace;

  /// No description provided for @importMergeDesc.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan judul baru, lewati duplikat.'**
  String get importMergeDesc;

  /// No description provided for @importReplaceDesc.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua judul saat ini dan ganti dengan backup.'**
  String get importReplaceDesc;

  /// No description provided for @confirmDeleteAll.
  ///
  /// In id, this message translates to:
  /// **'Ketik HAPUS SEMUA untuk konfirmasi'**
  String get confirmDeleteAll;

  /// No description provided for @confirmDeleteAllHint.
  ///
  /// In id, this message translates to:
  /// **'HAPUS SEMUA'**
  String get confirmDeleteAllHint;

  /// No description provided for @deleteAllTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus semua koleksi?'**
  String get deleteAllTitle;

  /// No description provided for @deleteAllDesc.
  ///
  /// In id, this message translates to:
  /// **'Semua judul tersimpan akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.'**
  String get deleteAllDesc;

  /// No description provided for @retryConnection.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retryConnection;

  /// No description provided for @stillOffline.
  ///
  /// In id, this message translates to:
  /// **'Masih offline. Periksa koneksi Anda.'**
  String get stillOffline;

  /// No description provided for @duplicateTitleWarning.
  ///
  /// In id, this message translates to:
  /// **'Judul ini sudah ada di koleksimu. Tetap tambahkan?'**
  String get duplicateTitleWarning;

  /// No description provided for @addAnyway.
  ///
  /// In id, this message translates to:
  /// **'Tetap Tambahkan'**
  String get addAnyway;

  /// No description provided for @entryAdded.
  ///
  /// In id, this message translates to:
  /// **'Ditambahkan ke koleksi.'**
  String get entryAdded;

  /// No description provided for @entryUpdated.
  ///
  /// In id, this message translates to:
  /// **'Entri diperbarui.'**
  String get entryUpdated;

  /// No description provided for @openCollection.
  ///
  /// In id, this message translates to:
  /// **'Buka Koleksi'**
  String get openCollection;

  /// No description provided for @viewOriginal.
  ///
  /// In id, this message translates to:
  /// **'Lihat Teks Asli'**
  String get viewOriginal;

  /// No description provided for @viewTranslation.
  ///
  /// In id, this message translates to:
  /// **'Lihat Terjemahan'**
  String get viewTranslation;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In id, this message translates to:
  /// **'Buang perubahan?'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesDesc.
  ///
  /// In id, this message translates to:
  /// **'Ada perubahan yang belum disimpan. Yakin ingin keluar?'**
  String get unsavedChangesDesc;

  /// No description provided for @discard.
  ///
  /// In id, this message translates to:
  /// **'Buang'**
  String get discard;

  /// No description provided for @imageCache.
  ///
  /// In id, this message translates to:
  /// **'Cache Gambar'**
  String get imageCache;

  /// No description provided for @keepEditing.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Edit'**
  String get keepEditing;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password baru'**
  String get confirmPasswordHint;

  /// No description provided for @confirmPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Password tidak cocok.'**
  String get confirmPasswordMismatch;

  /// No description provided for @profileSavedPasswordFailed.
  ///
  /// In id, this message translates to:
  /// **'Profil diperbarui, tapi password gagal diubah.'**
  String get profileSavedPasswordFailed;

  /// No description provided for @profilePasswordSaved.
  ///
  /// In id, this message translates to:
  /// **'Profil dan password diperbarui.'**
  String get profilePasswordSaved;

  /// No description provided for @passwordOnlySaved.
  ///
  /// In id, this message translates to:
  /// **'Password diperbarui.'**
  String get passwordOnlySaved;

  /// No description provided for @noPasswordRecovery.
  ///
  /// In id, this message translates to:
  /// **'Catatan: Aplikasi ini memakai login berbasis username. Jika lupa password, akun tidak dapat dipulihkan. Sebaiknya gunakan Backup & Restore secara rutin untuk menyimpan salinan koleksimu.'**
  String get noPasswordRecovery;

  /// No description provided for @passwordRecoveryFaqTitle.
  ///
  /// In id, this message translates to:
  /// **'Saya lupa password. Apa yang bisa dilakukan?'**
  String get passwordRecoveryFaqTitle;

  /// No description provided for @passwordRecoveryFaqDesc.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi ini memakai login username tanpa pemulihan email. Jika lupa password, akun tidak dapat dipulihkan. Selalu gunakan Backup & Restore secara rutin untuk menyimpan salinan koleksimu.'**
  String get passwordRecoveryFaqDesc;

  /// No description provided for @loginFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Login gagal'**
  String get loginFailedTitle;

  /// No description provided for @registerFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Registrasi gagal'**
  String get registerFailedTitle;

  /// No description provided for @networkErrorTitle.
  ///
  /// In id, this message translates to:
  /// **'Masalah koneksi'**
  String get networkErrorTitle;

  /// No description provided for @networkErrorDesc.
  ///
  /// In id, this message translates to:
  /// **'Periksa koneksi internet Anda dan coba lagi.'**
  String get networkErrorDesc;

  /// No description provided for @timeoutErrorDesc.
  ///
  /// In id, this message translates to:
  /// **'Server terlalu lama merespons. Coba lagi.'**
  String get timeoutErrorDesc;

  /// No description provided for @statusSuggestCompleted.
  ///
  /// In id, this message translates to:
  /// **'Tandai Selesai?'**
  String get statusSuggestCompleted;

  /// No description provided for @statusSuggestCompletedDesc.
  ///
  /// In id, this message translates to:
  /// **'Progres sudah mencapai total. Ubah status menjadi Selesai?'**
  String get statusSuggestCompletedDesc;

  /// No description provided for @yes.
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get no;

  /// No description provided for @usernameLabel.
  ///
  /// In id, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In id, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Password'**
  String get confirmPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get registerButton;

  /// No description provided for @processing.
  ///
  /// In id, this message translates to:
  /// **'Memproses...'**
  String get processing;

  /// No description provided for @showPassword.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan password'**
  String get hidePassword;

  /// No description provided for @loginHeader.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke Tsuzuki'**
  String get loginHeader;

  /// No description provided for @loginSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan lacak tontonan dan bacaanmu.'**
  String get loginSubtitle;

  /// No description provided for @noAccountYet.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun?'**
  String get noAccountYet;

  /// No description provided for @haveAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun?'**
  String get haveAccount;

  /// No description provided for @registerHeader.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun Tsuzuki'**
  String get registerHeader;

  /// No description provided for @registerSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Koleksimu akan tersimpan di akun dan bisa diakses dari perangkat lain.'**
  String get registerSubtitle;

  /// No description provided for @registerTerms.
  ///
  /// In id, this message translates to:
  /// **'Dengan mendaftar, kamu menyetujui bahwa data koleksi disimpan secara aman dan hanya dapat diakses oleh akunmu.'**
  String get registerTerms;

  /// No description provided for @usernameHint.
  ///
  /// In id, this message translates to:
  /// **'3–20 karakter: huruf kecil, angka, underscore.'**
  String get usernameHint;

  /// No description provided for @passwordHint.
  ///
  /// In id, this message translates to:
  /// **'Minimal 6 karakter.'**
  String get passwordHint;

  /// No description provided for @usernameRequired.
  ///
  /// In id, this message translates to:
  /// **'Username wajib diisi.'**
  String get usernameRequired;

  /// No description provided for @usernameMinLength.
  ///
  /// In id, this message translates to:
  /// **'Username minimal 3 karakter.'**
  String get usernameMinLength;

  /// No description provided for @usernameMaxLength.
  ///
  /// In id, this message translates to:
  /// **'Username maksimal 20 karakter.'**
  String get usernameMaxLength;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In id, this message translates to:
  /// **'Hanya huruf kecil, angka, dan underscore.'**
  String get usernameInvalidChars;

  /// No description provided for @passwordRequired.
  ///
  /// In id, this message translates to:
  /// **'Password wajib diisi.'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 6 karakter.'**
  String get passwordMinLength;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password wajib diisi.'**
  String get confirmPasswordRequired;

  /// No description provided for @confirmPasswordNotMatch.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi password tidak cocok.'**
  String get confirmPasswordNotMatch;

  /// No description provided for @displayNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Tampilan'**
  String get displayNameLabel;

  /// No description provided for @displayNameEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama tidak boleh kosong'**
  String get displayNameEmpty;

  /// No description provided for @displayNameMaxLength.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 30 karakter'**
  String get displayNameMaxLength;

  /// No description provided for @newPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Password Baru (Opsional)'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Biarkan kosong jika tidak ingin mengubah password'**
  String get newPasswordHint;

  /// No description provided for @chooseAvatar.
  ///
  /// In id, this message translates to:
  /// **'Pilih Avatar'**
  String get chooseAvatar;

  /// No description provided for @saveChanges.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In id, this message translates to:
  /// **'Profil berhasil diperbarui!'**
  String get profileUpdated;

  /// No description provided for @backupTitlesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Koleksi kosong, tidak ada yang diekspor.'**
  String get backupTitlesEmpty;

  /// No description provided for @backupFileInvalid.
  ///
  /// In id, this message translates to:
  /// **'File bukan JSON yang valid.'**
  String get backupFileInvalid;

  /// No description provided for @backupFormatInvalid.
  ///
  /// In id, this message translates to:
  /// **'Format file tidak dikenali. Harus berupa array JSON atau objek berisi daftar items.'**
  String get backupFormatInvalid;

  /// No description provided for @backupEmpty.
  ///
  /// In id, this message translates to:
  /// **'File kosong, tidak ada data untuk diimpor.'**
  String get backupEmpty;

  /// No description provided for @backupEntryInvalid.
  ///
  /// In id, this message translates to:
  /// **'Entri #{n}: format tidak valid.'**
  String backupEntryInvalid(Object n);

  /// No description provided for @backupEntryMissing.
  ///
  /// In id, this message translates to:
  /// **'Entri #{n}: \"{field}\" wajib diisi.'**
  String backupEntryMissing(Object field, Object n);

  /// No description provided for @backupEntryReadFail.
  ///
  /// In id, this message translates to:
  /// **'Entri #{n}: gagal dibaca.'**
  String backupEntryReadFail(Object n);

  /// No description provided for @storageCacheImages.
  ///
  /// In id, this message translates to:
  /// **'Cache Gambar'**
  String get storageCacheImages;

  /// No description provided for @storageCacheCollection.
  ///
  /// In id, this message translates to:
  /// **'Data Koleksi'**
  String get storageCacheCollection;

  /// No description provided for @storageCacheTranslation.
  ///
  /// In id, this message translates to:
  /// **'Cache Terjemahan'**
  String get storageCacheTranslation;

  /// No description provided for @storageClearSuccess.
  ///
  /// In id, this message translates to:
  /// **'Cache dihapus.'**
  String get storageClearSuccess;

  /// No description provided for @fieldStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get fieldStatus;

  /// No description provided for @fieldProgressUnit.
  ///
  /// In id, this message translates to:
  /// **'Progres ({unit})'**
  String fieldProgressUnit(Object unit);

  /// No description provided for @fieldTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get fieldTotal;

  /// No description provided for @fieldRating.
  ///
  /// In id, this message translates to:
  /// **'Rating (Opsional)'**
  String get fieldRating;

  /// No description provided for @fieldNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan (Opsional)'**
  String get fieldNote;

  /// No description provided for @fieldRequired.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi'**
  String get fieldRequired;

  /// No description provided for @fieldMustBeNumber.
  ///
  /// In id, this message translates to:
  /// **'Harus angka'**
  String get fieldMustBeNumber;

  /// No description provided for @fieldNotNegative.
  ///
  /// In id, this message translates to:
  /// **'Tidak boleh negatif'**
  String get fieldNotNegative;

  /// No description provided for @fieldExceedsTotal.
  ///
  /// In id, this message translates to:
  /// **'Melebihi total'**
  String get fieldExceedsTotal;

  /// No description provided for @noFavoritesTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Ada Favorit'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesDesc.
  ///
  /// In id, this message translates to:
  /// **'Tandai anime atau komik favoritmu dengan ikon hati.'**
  String get noFavoritesDesc;

  /// No description provided for @favoritesMarkHint.
  ///
  /// In id, this message translates to:
  /// **'Favorit'**
  String get favoritesMarkHint;

  /// No description provided for @gridView.
  ///
  /// In id, this message translates to:
  /// **'Tampilan Grid'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In id, this message translates to:
  /// **'Tampilan Daftar'**
  String get listView;

  /// No description provided for @filterTooltip.
  ///
  /// In id, this message translates to:
  /// **'Filter'**
  String get filterTooltip;

  /// No description provided for @reconnected.
  ///
  /// In id, this message translates to:
  /// **'Koneksi pulih.'**
  String get reconnected;

  /// No description provided for @nsfwSettingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Konten NSFW (18+)'**
  String get nsfwSettingsTitle;

  /// No description provided for @nsfwSettingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan konten dewasa di katalog. Default: nonaktif.'**
  String get nsfwSettingsSubtitle;

  /// No description provided for @nsfwEnableTitle.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Konten 18+?'**
  String get nsfwEnableTitle;

  /// No description provided for @nsfwEnableBody.
  ///
  /// In id, this message translates to:
  /// **'Dengan mengaktifkan, Anda menyatakan telah berusia 18 tahun atau lebih dan bersedia melihat konten dewasa. Konten ini hanya ditampilkan di katalog.'**
  String get nsfwEnableBody;

  /// No description provided for @refresh.
  ///
  /// In id, this message translates to:
  /// **'Segarkan'**
  String get refresh;

  /// No description provided for @imageCacheLimitLabel.
  ///
  /// In id, this message translates to:
  /// **'Batas cache gambar: {size}'**
  String imageCacheLimitLabel(Object size);

  /// No description provided for @confirmClearCacheTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus cache?'**
  String get confirmClearCacheTitle;

  /// No description provided for @confirmClearCacheBody.
  ///
  /// In id, this message translates to:
  /// **'Cache akan dihapus. Data di server tidak terpengaruh.'**
  String get confirmClearCacheBody;

  /// No description provided for @typeOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get typeOther;

  /// No description provided for @preImportBackupSaved.
  ///
  /// In id, this message translates to:
  /// **'Backup sebelumnya disimpan: {filename}'**
  String preImportBackupSaved(Object filename);

  /// No description provided for @imageCacheDesc.
  ///
  /// In id, this message translates to:
  /// **'Batasi ukuran cache gambar maksimal 100MB. Saat nonaktif, cache tidak dibatasi.'**
  String get imageCacheDesc;

  /// No description provided for @sortAddedDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal Ditambahkan'**
  String get sortAddedDate;

  /// No description provided for @sortAscending.
  ///
  /// In id, this message translates to:
  /// **'Naik'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In id, this message translates to:
  /// **'Turun'**
  String get sortDescending;

  /// No description provided for @sortDirection.
  ///
  /// In id, this message translates to:
  /// **'Arah'**
  String get sortDirection;

  /// No description provided for @selectItems.
  ///
  /// In id, this message translates to:
  /// **'Pilih'**
  String get selectItems;

  /// No description provided for @selectedCount.
  ///
  /// In id, this message translates to:
  /// **'{count} dipilih'**
  String selectedCount(Object count);

  /// No description provided for @selectAll.
  ///
  /// In id, this message translates to:
  /// **'Pilih Semua'**
  String get selectAll;

  /// No description provided for @changeLabel.
  ///
  /// In id, this message translates to:
  /// **'Ubah Label'**
  String get changeLabel;

  /// No description provided for @changeStatus.
  ///
  /// In id, this message translates to:
  /// **'Ubah Status'**
  String get changeStatus;

  /// No description provided for @removeLabel.
  ///
  /// In id, this message translates to:
  /// **'Hapus Label'**
  String get removeLabel;

  /// No description provided for @noLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanpa Label'**
  String get noLabel;

  /// No description provided for @confirmDeleteMultiple.
  ///
  /// In id, this message translates to:
  /// **'Hapus {count} koleksi yang dipilih?'**
  String confirmDeleteMultiple(Object count);

  /// No description provided for @confirmDeleteMultipleDesc.
  ///
  /// In id, this message translates to:
  /// **'Tindakan ini akan menghapus permanen judul yang dipilih dari koleksimu.'**
  String get confirmDeleteMultipleDesc;

  /// No description provided for @bulkDeleted.
  ///
  /// In id, this message translates to:
  /// **'{count} koleksi dihapus.'**
  String bulkDeleted(Object count);

  /// No description provided for @bulkUpdated.
  ///
  /// In id, this message translates to:
  /// **'{count} koleksi diperbarui.'**
  String bulkUpdated(Object count);

  /// No description provided for @comic.
  ///
  /// In id, this message translates to:
  /// **'Komik'**
  String get comic;

  /// No description provided for @sortPickOrder.
  ///
  /// In id, this message translates to:
  /// **'Urutkan berdasarkan'**
  String get sortPickOrder;

  /// No description provided for @showingResultsPartial.
  ///
  /// In id, this message translates to:
  /// **'Menampilkan {count} dari {total} · scroll untuk memuat lebih'**
  String showingResultsPartial(Object count, Object total);

  /// No description provided for @cardSizeTitle.
  ///
  /// In id, this message translates to:
  /// **'Ukuran Card'**
  String get cardSizeTitle;

  /// No description provided for @cardSizeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Sesuaikan ukuran card media'**
  String get cardSizeSubtitle;

  /// No description provided for @cardSizeSmall.
  ///
  /// In id, this message translates to:
  /// **'Kecil'**
  String get cardSizeSmall;

  /// No description provided for @cardSizeMedium.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get cardSizeMedium;

  /// No description provided for @cardSizeLarge.
  ///
  /// In id, this message translates to:
  /// **'Besar'**
  String get cardSizeLarge;

  /// Menu action to copy the title to clipboard
  ///
  /// In id, this message translates to:
  /// **' salin '**
  String get copy;

  /// Snackbar shown after copying the title
  ///
  /// In id, this message translates to:
  /// **'Disalin ke clipboard'**
  String get copiedToClipboard;

  /// No description provided for @displayMode.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get displayMode;

  /// No description provided for @displayGrid.
  ///
  /// In id, this message translates to:
  /// **'Grid'**
  String get displayGrid;

  /// No description provided for @displayList.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get displayList;

  /// No description provided for @displayCardSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran card'**
  String get displayCardSize;

  /// No description provided for @itemsPerRow.
  ///
  /// In id, this message translates to:
  /// **'Item per baris'**
  String get itemsPerRow;

  /// No description provided for @alternativeTitles.
  ///
  /// In id, this message translates to:
  /// **'Judul Alternatif'**
  String get alternativeTitles;

  /// No description provided for @randomPick.
  ///
  /// In id, this message translates to:
  /// **'Acak'**
  String get randomPick;

  /// No description provided for @debugInfo.
  ///
  /// In id, this message translates to:
  /// **'Debug Info'**
  String get debugInfo;

  /// No description provided for @helpSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari bantuan...'**
  String get helpSearchHint;

  /// No description provided for @helpNoResults.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil untuk pencarianmu.'**
  String get helpNoResults;

  /// No description provided for @helpCatGettingStarted.
  ///
  /// In id, this message translates to:
  /// **'Memulai'**
  String get helpCatGettingStarted;

  /// No description provided for @helpCatCatalog.
  ///
  /// In id, this message translates to:
  /// **'Katalog & Pencarian'**
  String get helpCatCatalog;

  /// No description provided for @helpCatCollection.
  ///
  /// In id, this message translates to:
  /// **'Koleksi & Progres'**
  String get helpCatCollection;

  /// No description provided for @helpCatSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan & Tampilan'**
  String get helpCatSettings;

  /// No description provided for @helpCatData.
  ///
  /// In id, this message translates to:
  /// **'Data & Backup'**
  String get helpCatData;

  /// No description provided for @helpCatTroubleshooting.
  ///
  /// In id, this message translates to:
  /// **'Troubleshooting'**
  String get helpCatTroubleshooting;

  /// No description provided for @faq5Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara mengubah ukuran card atau tampilan?'**
  String get faq5Title;

  /// No description provided for @faq5Desc.
  ///
  /// In id, this message translates to:
  /// **'Buka tab Katalog atau Koleksi, tekan ikon \'Tampilan\' (view_quilt) di kanan atas, lalu pilih Grid atau Daftar, pilih ukuran card (Kecil/Sedang/Besar), atau geser \'Item per baris\' (2-6). Perubahan berlaku seketika.'**
  String get faq5Desc;

  /// No description provided for @faq6Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara menambah label dengan warna custom?'**
  String get faq6Title;

  /// No description provided for @faq6Desc.
  ///
  /// In id, this message translates to:
  /// **'Buka Lainnya → Kelola Label. Tekan tombol +, masukkan nama, pilih warna dari palet, lalu simpan. Saat menambah atau mengedit koleksi, kamu bisa memilih label ini. Warnanya akan muncul di card koleksimu.'**
  String get faq6Desc;

  /// No description provided for @faq7Title.
  ///
  /// In id, this message translates to:
  /// **'Apa fungsi tombol Acak (shuffle)?'**
  String get faq7Title;

  /// No description provided for @faq7Desc.
  ///
  /// In id, this message translates to:
  /// **'Di tab Katalog, tekan ikon shuffle di bar atas. Aplikasi akan membuka halaman detail salah satu judul yang sedang dimuat secara acak. Berguna saat kamu bingung mau nonton atau baca apa.'**
  String get faq7Desc;

  /// No description provided for @faq8Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara backup atau restore koleksi?'**
  String get faq8Title;

  /// No description provided for @faq8Desc.
  ///
  /// In id, this message translates to:
  /// **'Buka Lainnya → Pengaturan → Backup & Restore. Tekan \'Ekspor\' untuk menyimpan koleksi sebagai file JSON (bagikan ke Drive/Files). Tekan \'Impor\' untuk memulihkan dari file. Kamu bisa pilih Gabungkan (tambah judul baru) atau Ganti Semua (hapus saat ini dan ganti).'**
  String get faq8Desc;

  /// No description provided for @faq9Title.
  ///
  /// In id, this message translates to:
  /// **'Mengapa perubahan saya gagal saat offline?'**
  String get faq9Title;

  /// No description provided for @faq9Desc.
  ///
  /// In id, this message translates to:
  /// **'Saat offline, aplikasi menampilkan data cache untuk mencegah konflik data. Operasi Tambah, Edit, dan Hapus memerlukan koneksi ke Supabase. Saat koneksi kembali, tekan \'Coba Lagi\' pada banner kuning mode offline untuk sinkronisasi.'**
  String get faq9Desc;

  /// No description provided for @faq10Title.
  ///
  /// In id, this message translates to:
  /// **'Apa itu Debug Info dan bagaimana menggunakannya?'**
  String get faq10Title;

  /// No description provided for @faq10Desc.
  ///
  /// In id, this message translates to:
  /// **'Buka Lainnya → Debug Info. Halaman ini menampilkan versi aplikasi, status koneksi (Supabase & AniList), pengaturan aktif, dan error terakhir. Tekan ikon copy di kanan atas untuk menyalin semua info — berguna untuk melaporkan bug ke developer.'**
  String get faq10Desc;

  /// No description provided for @faq11Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara mengaktifkan konten NSFW (18+)?'**
  String get faq11Title;

  /// No description provided for @faq11Desc.
  ///
  /// In id, this message translates to:
  /// **'Buka Lainnya → Pengaturan → toggle \'Konten NSFW (18+)\'. Kamu harus konfirmasi berusia 18+ sebelum mengaktifkan. Saat aktif, katalog akan menampilkan judul 18+ dengan badge merah \'18+\'. Pengaturan ini hanya mempengaruhi Katalog, bukan koleksimu.'**
  String get faq11Desc;

  /// No description provided for @faq12Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara memfilter katalog berdasarkan genre, tahun, atau status?'**
  String get faq12Title;

  /// No description provided for @faq12Desc.
  ///
  /// In id, this message translates to:
  /// **'Di tab Katalog, tekan ikon filter di bar atas untuk membuka panel filter. Kamu bisa filter berdasarkan genre, tag, tahun, status, skor minimum, dan urutan. Dari halaman detail mana pun, kamu bisa menekan chip tahun/status/genre untuk langsung menuju katalog terfilter.'**
  String get faq12Desc;

  /// No description provided for @faq13Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara menggunakan aksi massal (hapus, label, status)?'**
  String get faq13Title;

  /// No description provided for @faq13Desc.
  ///
  /// In id, this message translates to:
  /// **'Di tab Koleksi, tekan ikon checklist di bar atas (atau long-press salah satu item) untuk masuk mode pilih. Pilih beberapa item, lalu gunakan bar bawah untuk Hapus, Ubah Label, atau Ubah Status secara bersamaan.'**
  String get faq13Desc;

  /// No description provided for @faq14Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara menandai item sebagai Favorit?'**
  String get faq14Title;

  /// No description provided for @faq14Desc.
  ///
  /// In id, this message translates to:
  /// **'Buka halaman detail koleksi, lalu tekan ikon hati di kanan atas. Favorit muncul di Profil → Favorit Saya, di mana kamu bisa memfilter berdasarkan Anime atau Komik.'**
  String get faq14Desc;

  /// No description provided for @faq15Title.
  ///
  /// In id, this message translates to:
  /// **'Apa fungsi validasi progres?'**
  String get faq15Title;

  /// No description provided for @faq15Desc.
  ///
  /// In id, this message translates to:
  /// **'Progres tidak boleh negatif dan tidak boleh melebihi total episode/chapter. Jika kamu set status \'Selesai\', aplikasi akan menawarkan untuk mengisi otomatis progres ke total. Jika progres mencapai total, status akan otomatis berubah menjadi \'Selesai\'.'**
  String get faq15Desc;

  /// No description provided for @faq16Title.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana cara mengubah tema atau bahasa aplikasi?'**
  String get faq16Title;

  /// No description provided for @faq16Desc.
  ///
  /// In id, this message translates to:
  /// **'Buka Lainnya → Pengaturan. Di \'Tema Aplikasi\', pilih Gelap, Terang, atau Ikuti Sistem. Di \'Bahasa / Language\', pilih Indonesia atau English. Perubahan berlaku seketika di seluruh aplikasi.'**
  String get faq16Desc;

  /// No description provided for @faq17Title.
  ///
  /// In id, this message translates to:
  /// **'Apa arti ikon warna di card media?'**
  String get faq17Title;

  /// No description provided for @faq17Desc.
  ///
  /// In id, this message translates to:
  /// **'Titik warna di setiap card menunjukkan jenis media: Biru untuk Anime, Merah untuk Manga, Emas untuk Manhwa, Ungu untuk Manhua. Badge merah \'18+\' berarti judul mengandung konten dewasa.'**
  String get faq17Desc;
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
