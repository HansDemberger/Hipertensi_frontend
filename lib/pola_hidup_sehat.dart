import 'package:flutter/material.dart';

class PolaHidupSehat extends StatefulWidget {
  const PolaHidupSehat({super.key});

  @override
  State<PolaHidupSehat> createState() => _PolaHidupSehatState();
}

class _PolaHidupSehatState extends State<PolaHidupSehat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA), // Biru pastel lembut
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB), // Biru elegan
        title: const Text(
          'Pola Hidup Sehat',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'POLA HIDUP SEHAT AGAR TERHINDAR DARI PENYAKIT HIPERTENSI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B), // Biru abu tua
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _buildCard(
            icon: Icons.restaurant_menu,
            title: 'Makan Sehat',
            description:
                'Kurangi garam, perbanyak buah dan sayur, serta hindari makanan olahan dan cepat saji.',
          ),
          _buildCard(
            icon: Icons.directions_run,
            title: 'Aktif Berolahraga',
            description:
                'Lakukan aktivitas fisik 30 menit per hari, 5 hari seminggu seperti berjalan kaki, bersepeda, atau berenang.',
          ),
          _buildCard(
            icon: Icons.monitor_weight,
            title: 'Jaga Berat Badan',
            description:
                'Pertahankan berat badan ideal agar tekanan darah tetap normal dan stabil.',
          ),
          _buildCard(
            icon: Icons.smoke_free,
            title: 'Hindari Rokok & Alkohol',
            description:
                'Berhenti merokok dan batasi konsumsi alkohol untuk menjaga pembuluh darah tetap sehat.',
          ),
          _buildCard(
            icon: Icons.bedtime,
            title: 'Tidur & Kelola Stres',
            description:
                'Tidur minimal 7–8 jam setiap malam dan lakukan relaksasi untuk mengurangi stres.',
          ),
          _buildCard(
            icon: Icons.monitor_heart,
            title: 'Cek Tekanan Darah',
            description:
                'Pantau tekanan darah secara berkala, terutama jika ada riwayat hipertensi di keluarga.',
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black12,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF3B82F6).withOpacity(0.15),
              child: Icon(icon, size: 28, color: const Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
