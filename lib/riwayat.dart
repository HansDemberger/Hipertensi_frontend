// riwayat.dart
import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  final List<Map<String, String>> riwayatPrediksi;
  final Function(int) onDelete;

  const RiwayatPage({super.key, required this.riwayatPrediksi, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return riwayatPrediksi.isEmpty
        ? const Center(child: Text("Belum ada riwayat prediksi."))
        : ListView.builder(
            itemCount: riwayatPrediksi.length,
            itemBuilder: (context, index) {
              final item = riwayatPrediksi[index];
              final isRisk = item['hasil']?.contains("Berisiko") ?? false;

              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  border: Border.all(color: Colors.indigo.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isRisk ? Colors.orange : Colors.green,
                    child: Icon(
                      isRisk ? Icons.warning : Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  title: Text("Riwayat ${index + 1}"),
                  subtitle: Text("${item['hasil']}\nWaktu: ${item['waktu']}", style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onDelete(index),
                  ),
                ),
              );
            },
          );
  }
}