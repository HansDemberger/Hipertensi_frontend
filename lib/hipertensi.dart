import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Hipertensi extends StatefulWidget {
  const Hipertensi({super.key});

  @override
  State<Hipertensi> createState() => _HipertensiState();
}

class _HipertensiState extends State<Hipertensi> {
  Future<void> deleteRiwayat(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Token tidak ditemukan. Harap login ulang.")),
      );
      return;
    }

    final url = Uri.parse('http://localhost:5000/api/riwayat/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Riwayat berhasil dihapus.")),
        );
        await fetchRiwayatFromServer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus riwayat: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  int _currentIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  bool isLoadingRiwayat = false;

  int? usia;
  int? jenisKelamin;
  int? nyeriDada;
  int? ekgIstirahat;
  int? anginaOlahraga;
  int? kemiringanST;
  int? pembuluhDarah;
  int? thalassemia;

  String hasil = "";
  List<Map<String, String>> riwayatPrediksi = [];

  final List<int> usiaList = List.generate(61, (i) => 20 + i);
  // final TextEditingController usiaController = TextEditingController();


  // Data jenis kelamin
final Map<int, String> GENDER_MAP = {
  0: "Perempuan",
  1: "Laki-laki"
};

// Jenis nyeri dada yang dirasakan
final Map<int, String> NYERI_DADA_MAP = {
  0: "Tidak merasakan nyeri dada",
  1: "Nyeri dada khas (Typical Angina)"
};

// Hasil pemeriksaan EKG (rekam jantung)
final Map<int, String> EKG_MAP = {
  0: "Hasil EKG normal",
  1: "Hasil EKG tidak normal"
};

// Riwayat angina (nyeri dada saat aktivitas)
final Map<int, String> ANGINA_MAP = {
  0: "Tidak pernah mengalami angina",
  1: "Pernah mengalami angina"
};

// Hasil uji treadmill (kemiringan ST saat tes jantung)
final Map<int, String> KEMIRINGAN_MAP = {
  0: "Menurun",
  1: "Meningkat"
};

// Kondisi pembuluh darah koroner
final Map<int, String> PEMBULUH_MAP = {
  0: "Pembuluh darah normal",
  1: "Ada penyumbatan di pembuluh darah"
};

// Hasil tes Thalium (pemeriksaan aliran darah jantung)
final Map<int, String> THAL_MAP = {
  1: "Normal",
  2: "Ada kelainan tetap pada aliran darah"
};


  @override
  void initState() {
    super.initState();
    // Muat riwayat saat aplikasi dimulai
    fetchRiwayatFromServer();
  }

  Future<void> fetchRiwayatFromServer() async {
    setState(() {
      isLoadingRiwayat = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() {
        hasil = "⚠ Token tidak ditemukan. Harap login ulang.";
        isLoadingRiwayat = false;
      });
      return;
    }

    final url = Uri.parse('http://localhost:5000/api/riwayat');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> riwayatList = data['data'];

        setState(() {
          riwayatPrediksi = riwayatList.map<Map<String, String>>((item) {
            // Perbaiki mapping hasil prediksi
            // Asumsikan ada field 'prediction' atau 'hasil_prediksi' di response
            // Jika tidak ada, kita bisa menggunakan logika berdasarkan data yang ada
            String hasilText = '✅ Tidak Berisiko'; // default

            // Jika ada field prediction di response
            if (item.containsKey('prediction')) {
              hasilText = item['prediction'] == 1
                  ? '⚠ Berisiko Hipertensi'
                  : '✅ Tidak Berisiko';
            }
            // Jika tidak ada field prediction, kita bisa menggunakan logika lain
            // atau menambahkan field prediction ke database

            final waktu = item['created_at'] != null
                ? DateFormat('dd MMM yyyy - HH:mm')
                    .format(DateTime.parse(item['created_at']))
                : "Tidak diketahui";

            return {
              'hasil': hasilText,
              'waktu': waktu,
              'id': item['id'].toString(),
            };
          }).toList();

          // Urutkan berdasarkan waktu terbaru
          riwayatPrediksi.sort((a, b) => b['waktu']!.compareTo(a['waktu']!));
          isLoadingRiwayat = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          riwayatPrediksi = [];
          isLoadingRiwayat = false;
        });
      } else {
        setState(() {
          hasil =
              "⚠ Gagal mengambil riwayat (status: ${response.statusCode}): ${response.body}";
          isLoadingRiwayat = false;
        });
      }
    } catch (e) {
      setState(() {
        hasil = "❌ Terjadi kesalahan saat mengambil riwayat: $e";
        isLoadingRiwayat = false;
      });
    }
  }

  Future<void> getHipertensi() async {
    // Validasi input
    if (usia == null ||
        jenisKelamin == null ||
        nyeriDada == null ||
        ekgIstirahat == null ||
        anginaOlahraga == null ||
        kemiringanST == null ||
        pembuluhDarah == null ||
        thalassemia == null) {
      setState(() {
        hasil = "⚠ Harap lengkapi semua field sebelum melakukan prediksi!";
      });
      return;
    }

    final url = Uri.parse('http://localhost:5000/api/predict-and-save');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() {
        hasil = "⚠ Token tidak ditemukan. Harap login ulang.";
      });
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "usia": usia,
          "jenis_kelamin": jenisKelamin,
          "nyeri_dada": nyeriDada,
          "ekg_istirahat": ekgIstirahat,
          "angina_olahraga": anginaOlahraga,
          "kemiringan_st": kemiringanST,
          "pembuluh_darah": pembuluhDarah,
          "thalassemia": thalassemia,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final status = data['prediction'] == 1
            ? '⚠ Berisiko Hipertensi'
            : '✅ Tidak Berisiko';
        final confidence = "${(data['confidence'] * 100).toStringAsFixed(2)}%";

        setState(() {
          hasil =
              "$status\nTingkat Keyakinan: $confidence\nCatatan: ${data['message']}";
        });

        // Refresh riwayat setelah prediksi berhasil
        await fetchRiwayatFromServer();

        // Tampilkan snackbar untuk konfirmasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Prediksi berhasil disimpan!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          hasil =
              "⚠ Gagal melakukan prediksi (status: ${response.statusCode}):\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        hasil = "❌ Terjadi kesalahan: $e";
      });
    }
  }

  void clearFields() {
    setState(() {
      usia = null;
      jenisKelamin = null;
      nyeriDada = null;
      ekgIstirahat = null;
      anginaOlahraga = null;
      kemiringanST = null;
      pembuluhDarah = null;
      thalassemia = null;
      hasil = "";
    });
  }

  Widget buildDropdown({
    required String label,
    required Map<int, String> options,
    required int? selectedValue,
    required Function(int?) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        value: selectedValue,
        items: options.entries
            .map((entry) => DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.indigo),
          filled: true,
          fillColor: Colors.indigo.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownUsia() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        value: usia,
        items: usiaList
            .map((u) => DropdownMenuItem<int>(
                  value: u,
                  child: Text(u.toString()),
                ))
            .toList(),
        onChanged: (val) => setState(() => usia = val),
        decoration: InputDecoration(
          labelText: "Usia",
          prefixIcon: Icon(Icons.cake, color: Colors.indigo),
          filled: true,
          fillColor: Colors.indigo.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
// Widget buildTextFieldUsia() {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
//     child: TextFormField(
//       // controller: usiaController,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         labelText: "Masukkan Usia",
//         prefixIcon: const Icon(Icons.cake, color: Colors.indigo),
//         filled: true,
//         fillColor: Colors.indigo.shade50,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//     ),
//   );
// }

  Widget buildHomeContent() {
    return SingleChildScrollView(
      key: const PageStorageKey('homePage'),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text("Masukkan Data Anda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          buildDropdownUsia(),
          // buildTextFieldUsia(),

          buildDropdown(
            label: "Jenis Kelamin",
            options: GENDER_MAP,
            selectedValue: jenisKelamin,
            onChanged: (val) => setState(() => jenisKelamin = val),
            icon: Icons.person,
          ),
          buildDropdown(
            label: "Tipe Nyeri Dada",
            options: NYERI_DADA_MAP,
            selectedValue: nyeriDada,
            onChanged: (val) => setState(() => nyeriDada = val),
            icon: Icons.favorite,
          ),
          buildDropdown(
            label: "EKG Saat Istirahat",
            options: EKG_MAP,
            selectedValue: ekgIstirahat,
            onChanged: (val) => setState(() => ekgIstirahat = val),
            icon: Icons.monitor_heart,
          ),
          buildDropdown(
            label: "Angina/Nyeri Saat Olahraga",
            options: ANGINA_MAP,
            selectedValue: anginaOlahraga,
            onChanged: (val) => setState(() => anginaOlahraga = val),
            icon: Icons.directions_walk,
          ),
          buildDropdown(
            label: "Kemiringan Segmen ST",
            options: KEMIRINGAN_MAP,
            selectedValue: kemiringanST,
            onChanged: (val) => setState(() => kemiringanST = val),
            icon: Icons.trending_up,
          ),
          buildDropdown(
            label: "Kondisi Pembuluh Darah",
            options: PEMBULUH_MAP,
            selectedValue: pembuluhDarah,
            onChanged: (val) => setState(() => pembuluhDarah = val),
            icon: Icons.bloodtype,
          ),
          buildDropdown(
            label: "Thalassemia",
            options: THAL_MAP,
            selectedValue: thalassemia,
            onChanged: (val) => setState(() => thalassemia = val),
            icon: Icons.healing,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: clearFields,
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  side: const BorderSide(color: Colors.indigo),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Reset",
                    style: TextStyle(
                        color: Colors.indigo, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: getHipertensi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Prediksi",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Hasil Prediksi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (hasil.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Text(hasil,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildRiwayatPage() {
    if (isLoadingRiwayat) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (riwayatPrediksi.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text("Belum ada riwayat prediksi.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchRiwayatFromServer,
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchRiwayatFromServer,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: riwayatPrediksi.length,
        itemBuilder: (context, index) {
          final item = riwayatPrediksi[index];
          final isRisk = item['hasil']?.contains("Berisiko") ?? false;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              border: Border.all(color: Colors.indigo.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: isRisk ? Colors.orange : Colors.green,
                child: Icon(
                  isRisk
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: Colors.white,
                ),
              ),
              title: Text("Riwayat ${index + 1}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['hasil'] ?? "",
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text("Waktu: ${item['waktu']}",
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    onPressed: fetchRiwayatFromServer,
                    tooltip: "Segarkan",
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    tooltip: "Hapus Riwayat",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Hapus Riwayat"),
                          content: const Text(
                              "Apakah Anda yakin ingin menghapus riwayat ini?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Batal"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // tutup dialog
                                deleteRiwayat(item['id']!);
                              },
                              child: const Text("Hapus",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4285F4),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: const Text("Prediksi Hipertensi",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: PageStorage(
        bucket: bucket,
        child: _currentIndex == 0 ? buildHomeContent() : buildRiwayatPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: const Color(0xFF4285F4),
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Refresh riwayat saat tab riwayat dibuka
          if (index == 1) {
            fetchRiwayatFromServer();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}
