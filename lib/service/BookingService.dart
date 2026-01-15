import 'dart:convert';
import 'package:http/http.dart' as http;
// Pastikan nama class di file ini benar-benar 'BookingModel'
import 'package:mobile/model/ModelBooking.dart';

class BookingService {
  // 1. Bersihkan URL dari query parameter (?pricePerHour=5000)
  // karena harga sudah dikirim di dalam body JSON (totalPrice)
  static const String baseUrl = "http://10.57.107.139:8002/api/bookings";

  Future<BookingModel?> createBooking({
    required int gedungId,
    required String name,
    required int duration,
    required double price
  }) async {
    try {
      // Menyiapkan data JSON sesuai format yang diharapkan backend
      final Map<String, dynamic> data = {
        "gedungId": gedungId,
        "customerName": name,
        // Backend Java/Spring biasanya tidak butuh milidetik yang terlalu panjang
        "bookingDate": DateTime.now().toIso8601String().split('.')[0],
        "durationHours": duration,
        "totalPrice": price,
        "paymentProof": null,
        "status": "PENDING"
      };

      print("Mengirim data ke $baseUrl: ${jsonEncode(data)}"); // Debugging log

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );

      // Log status code untuk memudahkan pengecekan di terminal
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return BookingModel.fromJson(jsonDecode(response.body));
      } else {
        // Ini akan muncul di terminal jika gagal (misal: error 400 atau 500)
        print("Server Error Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Network Error: $e");
      return null;
    }
  }
}