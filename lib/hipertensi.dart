import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Hipertensi extends StatefulWidget {
  const Hipertensi({super.key});

  @override
  State<Hipertensi> createState() => _HipertensiState();
}

class _HipertensiState extends State<Hipertensi> {
  int _currentIndex = 0;
  final PageStorageBucket bucket = PageStorageBucket();

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

  final Map<int, String> GENDER_MAP = {0: "Perempuan", 1: "Laki-laki"};
  final Map<int, String> NYERI_DADA_MAP = {
    0: "Tidak Ada",
    1: "Nyeri Dada Tipe Typical"
  };
  final Map<int, String> EKG_MAP = {0: "Normal", 1: "Abnormal"};
  final Map<int, String> ANGINA_MAP = {0: "Tidak", 1: "Ya"};
  final Map<int, String> KEMIRINGAN_MAP = {
    0: "Menurun",
    1: "Meningkat"
  };
  final Map<int, String> PEMBULUH_MAP = {
    0: "Normal",
    1: "Tersumbat"
  };
  final Map<int, String> THAL_MAP = {1: "Normal", 2: "Kelainan Tetap"};

  Future<void> getHipertensi() async {
    final url = Uri.parse('http://localhost:5000/api/predict-and-save');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
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
        final status =
            data['prediction'] == 1 ? '⚠ Berisiko Hipertensi' : '✅ Tidak Berisiko';
        final confidence = "${(data['confidence'] * 100).toStringAsFixed(2)}%";

        setState(() {
          hasil = "$status\nTingkat Keyakinan: $confidence\nCatatan: ${data['message']}";
          String hasilRiwayat = "$status\nTingkat Keyakinan: $confidence";
          String waktuSekarang =
              DateFormat('dd MMM yyyy - HH:mm').format(DateTime.now());

          riwayatPrediksi.add({
            'hasil': hasilRiwayat,
            'waktu': waktuSekarang,
          });
        });
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

  Widget buildHomeContent() {
    return SingleChildScrollView(
      key: const PageStorageKey('homePage'),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text("Masukkan Data Anda",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          buildDropdownUsia(),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  side: const BorderSide(color: Colors.indigo),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Reset",
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: getHipertensi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Prediksi",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    return riwayatPrediksi.isEmpty
        ? const Center(
            child: Text("Belum ada riwayat prediksi.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          )
        : ListView.builder(
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        riwayatPrediksi.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
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
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );
  }
}
