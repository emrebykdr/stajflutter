import 'package:flutter/material.dart';
import 'video_player_screen.dart';
import 'reels_screen.dart';
import 'notification_screen.dart';
import 'map_screen.dart';
import 'test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staj Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ModuleCard(
            icon: Icons.play_circle,
            title: '1. Video Player Sayfasi',
            subtitle: 'Native + YouTube video oynatma',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VideoPlayerScreen()),
            ),
          ),
          _ModuleCard(
            icon: Icons.video_library,
            title: '2. Reels Sayfasi',
            subtitle: 'Instagram Reels tarzi video akisi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReelsScreen()),
            ),
          ),
          _ModuleCard(
            icon: Icons.notifications_active,
            title: '3. Bildirim Sistemi',
            subtitle: '5 saniye sonra local notification',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
          ),
          _ModuleCard(
            icon: Icons.map,
            title: '4. Google Maps + Konum',
            subtitle: 'Harita ve kullanici konumu',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapScreen()),
            ),
          ),
          _ModuleCard(
            icon: Icons.science,
            title: '5. Loading Deneme',
            subtitle: '5sn loading ekrani',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TestScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
