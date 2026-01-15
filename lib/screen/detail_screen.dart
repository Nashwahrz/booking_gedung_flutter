import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/venue_model.dart';
import '../service/venue_service.dart';
import 'form_screen.dart';
import 'booking_screen.dart'; // Menghubungkan ke kodingan booking tadi

class DetailScreen extends StatelessWidget {
  final Venue venue;
  final VenueService _apiService = VenueService();

  DetailScreen({super.key, required this.venue});

  String formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  Future<void> _deleteVenue(BuildContext context) async {
    // Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Gedung?"),
        content: const Text("Data ini akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _apiService.deleteVenue(venue.id!);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
        Navigator.pop(context); // Kembali ke Home
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(venue.name, style: const TextStyle(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
              background: Container(color: Colors.teal), // Ganti dengan Image.network nanti
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Navigasi ke FormScreen Mode Edit
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FormScreen(venue: venue)));
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteVenue(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatRupiah(venue.pricePerHour), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.teal, fontWeight: FontWeight.bold)),
                      Chip(label: Text("${venue.capacity} Orang"), avatar: const Icon(Icons.people)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(children: [Icon(Icons.location_on, color: Colors.grey), SizedBox(width: 8), Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold))]),
                  Text(venue.location, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(venue.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 100), // Memberi ruang agar tidak tertutup tombol bottomNavigationBar
                ],
              ),
            ),
          ),
        ],
      ),
      // Integrasi Tombol Booking Baru
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            // Navigasi dengan data yang sesuai kodingan BookingScreen sebelumnya
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingPage(
                  idGedung: venue.id!,
                  namaGedung: venue.name,
                  hargaPerJam: venue.pricePerHour.toDouble(),
                ),
              ),
            );
          },
          child: const Text("BOOKING SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}