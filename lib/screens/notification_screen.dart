import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isScheduled = false;
  bool _isInitialized = false;
  String? _error;
  String? _status;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final result = await _notificationService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = result;
          _status = result ? 'Hazir' : null;
          if (!result) _error = 'Bildirim baslatilamadi';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Baslatma hatasi: $e');
      }
    }
  }

  Future<void> _sendNotification() async {
    if (!_isInitialized) return;

    setState(() {
      _isScheduled = true;
      _error = null;
      _status = 'Bekleniyor... 5 saniye';
    });

    try {
      await Future.delayed(const Duration(seconds: 5));

      await _notificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Test Bildirimi',
        body: 'Bu bir test bildirimidir!',
      );

      if (mounted) {
        setState(() {
          _isScheduled = false;
          _status = 'Bildirim gonderildi!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildirim gonderildi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScheduled = false;
          _error = 'Hata: $e';
          _status = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Sistemi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_active,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Local Notification Demo',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Butona tikladiginizda 5 saniye sonra\ntelefonunuza bildirim gonderilecektir.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              if (_status != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _status!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: (_isScheduled || !_isInitialized)
                      ? null
                      : _sendNotification,
                  icon: _isScheduled
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isScheduled ? 'Bekleniyor...' : 'Bildirim Gonder',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
