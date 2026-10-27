import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ExpansionTile(
            title: const Text('Bagaimana cara menambahkan anime/komik ke koleksi?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Buka tab Katalog, cari judul yang diinginkan, lalu tekan kartu tersebut. Di halaman detail, tekan tombol "Tambah ke Koleksi".'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Apa fungsi tombol +1 pada kartu koleksi?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Tombol +1 berfungsi untuk menambah progres (episode/chapter) dengan cepat tanpa harus membuka halaman edit. Jika progres mencapai total, status otomatis menjadi "Selesai".'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Mengapa data saya tidak bisa diubah saat offline?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Saat offline, aplikasi menampilkan data cache untuk mencegah konflik data. Operasi Tambah, Edit, dan Hapus memerlukan koneksi internet ke database.'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Bagaimana cara mengubah tema aplikasi?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Buka tab Lainnya, lalu pilih menu "Tema Aplikasi". Anda dapat memilih mode Gelap, Terang, atau mengikuti sistem.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}