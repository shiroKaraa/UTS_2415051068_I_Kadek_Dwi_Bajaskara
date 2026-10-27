// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Tsuzuki';

  @override
  String get navHome => 'Home';

  @override
  String get navCatalog => 'Katalog';

  @override
  String get navCollection => 'Koleksi';

  @override
  String get navOther => 'Lainnya';

  @override
  String get navProfile => 'Profil';

  @override
  String get welcome => 'Halo, Selamat Datang!';

  @override
  String get subWelcome => 'Terus lacak progres tontonan dan bacaanmu.';

  @override
  String get continueWatching => 'Lanjutkan';

  @override
  String get popularAnime => 'Anime Populer';

  @override
  String get popularManga => 'Komik Populer';

  @override
  String get seeAll => 'Lihat Semua';

  @override
  String get searchHint => 'Cari judul...';

  @override
  String get addToCollection => 'Tambah ke Koleksi';

  @override
  String get emptyCollection => 'Koleksi Kosong';

  @override
  String get emptyCollectionDesc =>
      'Cari judul di Katalog dan tambahkan yang pertama.';

  @override
  String get statTotal => 'Total';

  @override
  String get statReading => 'Sedang';

  @override
  String get statCompleted => 'Selesai';

  @override
  String get noTrackedYet => 'Belum ada yang dilacak.';

  @override
  String get searchFirst => 'Cari anime atau komik pertamamu.';

  @override
  String get searchNow => 'Cari Sekarang';

  @override
  String get progress => 'Progres';

  @override
  String get onboardingTitle => 'Selamat Datang di Tsuzuki';

  @override
  String get onboardingDesc =>
      'Aplikasi pelacak progres tontonan Anime dan bacaan Komik favoritmu.';

  @override
  String get skip => 'Lewati';

  @override
  String get next => 'Lanjut';

  @override
  String get getStarted => 'Mulai Sekarang';

  @override
  String get filterCatalog => 'Filter Katalog';

  @override
  String get allGenres => 'Semua Genre';

  @override
  String get allYears => 'Semua Tahun';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Terapkan';

  @override
  String get searchInCollection => 'Cari di koleksimu...';

  @override
  String get activeFilter => 'Filter Aktif';

  @override
  String get clearAll => 'Hapus Semua';

  @override
  String get offlineMode => 'Mode Offline: Menampilkan data tersimpan.';

  @override
  String get noResults => 'Tidak Ada Hasil';

  @override
  String get noResultsDesc => 'Coba ubah kata kunci atau filter pencarianmu.';

  @override
  String get resetFilter => 'Reset Filter';

  @override
  String get synopsis => 'Sinopsis';

  @override
  String get noSynopsis => 'Tidak ada sinopsis.';

  @override
  String get delete => 'Hapus';

  @override
  String get cancel => 'Batal';

  @override
  String get edit => 'Edit';

  @override
  String get undo => 'Urungkan';

  @override
  String get settings => 'Pengaturan';

  @override
  String get theme => 'Tema Aplikasi';

  @override
  String get light => 'Terang';

  @override
  String get dark => 'Gelap';

  @override
  String get system => 'Ikuti Sistem';

  @override
  String get language => 'Bahasa / Language';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get backupDesc => 'Ekspor atau impor koleksi Anda';

  @override
  String get manageCategories => 'Kelola Kategori';

  @override
  String get statistics => 'Statistik';

  @override
  String get storage => 'Data dan penyimpanan';

  @override
  String get about => 'Tentang';

  @override
  String get help => 'Bantuan';

  @override
  String get profile => 'Profil';

  @override
  String get totalTitles => 'Total Judul';

  @override
  String get completed => 'Selesai';

  @override
  String get estimatedTime => 'Estimasi Waktu Menonton';

  @override
  String get days => 'Hari';

  @override
  String get activityDetails => 'Rincian Aktivitas';

  @override
  String get anime => 'Anime';

  @override
  String trackedTitles(Object count) {
    return '$count Judul dilacak';
  }

  @override
  String get episodes => 'Episode';

  @override
  String get manga => 'Manga / Komik';

  @override
  String get chapters => 'Chapter';

  @override
  String get estimatedVolumes => 'Estimasi Volume';

  @override
  String get volumeRatio => 'Berdasarkan rasio 9 Chapter/Volume';

  @override
  String get volumes => 'Volume';

  @override
  String get statsNote =>
      'Catatan: Estimasi waktu menonton dihitung dari 1 episode = 24 menit.';

  @override
  String get errorLoadData => 'Gagal Memuat Data';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get errorEmptyData => 'Belum Ada Data';

  @override
  String get errorPopularData => 'Data populer tidak dapat dimuat.';

  @override
  String get noCategory => 'Belum ada kategori kustom.';

  @override
  String get addCategory => 'Tambah Kategori';

  @override
  String get editCategory => 'Edit Kategori';

  @override
  String get categoryName => 'Nama Kategori';

  @override
  String get progressUnit => 'Satuan Progres (misal: Bagian, Halaman, Tugas)';

  @override
  String get save => 'Simpan';

  @override
  String get deleteCategory => 'Hapus Kategori?';

  @override
  String deleteCategoryDesc(Object name) {
    return 'Menghapus kategori \"$name\" akan menghapus semua entri di dalamnya. Lanjutkan?';
  }

  @override
  String get categoryAdded => 'Kategori ditambahkan.';

  @override
  String get categoryUpdated => 'Kategori diperbarui.';

  @override
  String get categoryDeleted => 'Kategori dihapus.';

  @override
  String get failedAddCategory => 'Gagal menambah kategori';

  @override
  String get failedEditCategory => 'Gagal mengedit kategori';

  @override
  String get failedDeleteCategory => 'Gagal menghapus kategori';

  @override
  String get deviceIdNotAvailable => 'ID Perangkat belum tersedia.';

  @override
  String idCopied(Object id) {
    return 'ID disalin: $id';
  }

  @override
  String get sourceData => 'Sumber Data Katalog';

  @override
  String get sourceDataDesc =>
      'Data anime & manga disediakan oleh AniList API (GraphQL).';

  @override
  String get storageData => 'Penyimpanan Data';

  @override
  String get storageDataDesc =>
      'Koleksi pribadi disimpan dengan aman di Supabase (PostgreSQL).';

  @override
  String get deviceId => 'ID Perangkat';

  @override
  String get loadingId => 'Memuat ID...';

  @override
  String get classLabel => 'Kelas';

  @override
  String get nimLabel => 'NIM';

  @override
  String get supportUs => 'Dukung Kami';

  @override
  String get supportThankYou => 'Terima kasih atas dukungan Anda!';

  @override
  String get aboutApp => 'Tentang Aplikasi';

  @override
  String get version => 'Versi';

  @override
  String get developer => 'Developer';

  @override
  String get course => 'Mata Kuliah';

  @override
  String get dataSource => 'Sumber Data';

  @override
  String get copyright => '© 2026 Tsuzuki App';

  @override
  String get appDescription =>
      'Aplikasi pelacak progres tontonan Anime dan bacaan Komik (Manga, Manhwa, Manhua).';

  @override
  String get helpFaq => 'Bantuan & FAQ';

  @override
  String get faq1Title => 'Bagaimana cara menambahkan anime/komik ke koleksi?';

  @override
  String get faq1Desc =>
      'Buka tab Katalog, cari judul yang diinginkan, lalu tekan kartu tersebut. Di halaman detail, tekan tombol \"Tambah ke Koleksi\".';

  @override
  String get faq2Title => 'Apa fungsi tombol +1 pada kartu koleksi?';

  @override
  String get faq2Desc =>
      'Tombol +1 berfungsi untuk menambah progres (episode/chapter) dengan cepat tanpa harus membuka halaman edit. Jika progres mencapai total, status otomatis menjadi \"Selesai\".';

  @override
  String get faq3Title => 'Mengapa data saya tidak bisa diubah saat offline?';

  @override
  String get faq3Desc =>
      'Saat offline, aplikasi menampilkan data cache untuk mencegah konflik data. Operasi Tambah, Edit, dan Hapus memerlukan koneksi internet ke database.';

  @override
  String get faq4Title => 'Bagaimana cara mengubah tema aplikasi?';

  @override
  String get faq4Desc =>
      'Buka tab Lainnya, lalu pilih menu \"Tema Aplikasi\". Anda dapat memilih mode Gelap, Terang, atau mengikuti sistem.';

  @override
  String get statusPlanned => 'Direncanakan';

  @override
  String get statusOngoing => 'Sedang';

  @override
  String get statusCompleted => 'Selesai';

  @override
  String get statusPaused => 'Ditunda';

  @override
  String get statusDropped => 'Dihentikan';

  @override
  String get note => 'Catatan';

  @override
  String get editEntry => 'Edit Entri Ini';

  @override
  String get noNotes => 'Tidak ada catatan.';
}
