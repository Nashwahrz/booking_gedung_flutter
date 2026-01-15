import 'dart:convert'; // Wajib untuk decode Base64
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format rupiah
import '../model/venue_model.dart';
import '../service/venue_service.dart';
import 'detail_screen.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VenueService _apiService = VenueService();
  late Future<List<Venue>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Fungsi untuk refresh data
  Future<void> _refreshData() async {
    setState(() {
      _venuesFuture = _apiService.getAllVenues();
    });
  }

  // Helper format rupiah
  String formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  // --- HELPER UNTUK MENAMPILKAN GAMBAR ---
  Widget _buildVenueImage(List<String> images) {
    if (images.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }

    String firstImage = images.first;

    // Jika formatnya Base64 (Diawali dengan data:image)
    if (firstImage.startsWith('data:image')) {
      try {
        final base64String = firstImage.split(',').last; // Buang header data:image/xxx;base64,
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
        );
      } catch (e) {
        return const Icon(Icons.broken_image);
      }
    }

    // Jika formatnya URL Internet biasa
    return Image.network(
      firstImage,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Gedung'),
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen()),
          );
          _refreshData();
        },
        label: const Text("Tambah Gedung"),
        icon: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Venue>>(
          future: _venuesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada data gedung."));
            }

            final venues = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final venue = venues[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailScreen(venue: venue)),
                      );
                      _refreshData();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- BAGIAN GAMBAR DINAMIS ---
                        SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: _buildVenueImage(venue.images),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                venue.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      venue.location,
                                      style: const TextStyle(color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${formatRupiah(venue.pricePerHour)} / jam",
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Kapasitas: ${venue.capacity}",
                                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}