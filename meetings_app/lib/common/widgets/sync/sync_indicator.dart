import 'package:flutter/material.dart';
import '../../../features/app/services/sync_service.dart';
import '../../../utils/constants/colors.dart';

/// Widget que muestra el estado de sincronización
class SyncIndicator extends StatefulWidget {
  final bool showText;
  final double size;
  
  const SyncIndicator({
    super.key,
    this.showText = false,
    this.size = 20,
  });

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    // Verificar estado inicial
    _checkSyncState();
    
    // Verificar periódicamente el estado
    _startStateCheck();
  }
  
  void _checkSyncState() {
    if (SyncService.instance.isSyncing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }
  
  void _startStateCheck() {
    // Verificar estado cada segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _checkSyncState();
        _startStateCheck();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _createSyncStream(),
      builder: (context, snapshot) {
        final isSyncing = snapshot.data ?? false;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: Icon(
                    isSyncing ? Icons.sync : Icons.sync_disabled,
                    color: isSyncing ? LColors.primary : Colors.grey,
                    size: widget.size,
                  ),
                );
              },
            ),
            if (widget.showText) ...[
              const SizedBox(width: 8),
              Text(
                isSyncing ? 'Sincronizando...' : 'Sincronizado',
                style: TextStyle(
                  color: isSyncing ? LColors.primary : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
  
  Stream<bool> _createSyncStream() async* {
    while (true) {
      yield SyncService.instance.isSyncing;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
} 