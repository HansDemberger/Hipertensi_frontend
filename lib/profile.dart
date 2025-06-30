import 'package:flutter/material.dart';
import 'login.dart'; // Pastikan path-nya sesuai dengan struktur foldermu

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pop(context); // Kembali ke beranda
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FC),
      body: Column(
        children: [
          const SizedBox(height: 48), // Jarak dari atas
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Foto Profil
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('lib/assets/hans.jpg'),
            backgroundColor: Colors.grey,
          ),

          const SizedBox(height: 16),

          // Nama
          const Text(
            'Hans Demberger S',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),

          const SizedBox(height: 4),

          // Email
          const Text(
            'hans@email.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 30),

          // Menu
          Expanded(
            child: ListView(
              children: [
                _buildProfileMenuItem(Icons.edit, 'Edit Profil', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Edit Profil ditekan")),
                  );
                }),
                _buildProfileMenuItem(Icons.info, 'Tentang Aplikasi', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tentang Aplikasi ditekan")),
                  );
                }),
                _buildProfileMenuItem(Icons.logout, 'Keluar', () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF3B82F6),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(
      IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3B82F6)),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF2C3E50)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
