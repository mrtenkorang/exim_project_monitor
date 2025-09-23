import 'package:exim_project_monitor/features/farmer_management/add_farmer.dart';
import 'package:flutter/material.dart';
import '../farm_management/add_farm.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Timer state
  final ValueNotifier<Duration> _syncDuration = ValueNotifier<Duration>(Duration.zero);
  Timer? _syncTimer;

  @override
  void dispose() {
    _syncTimer?.cancel();
    _syncDuration.dispose();
    super.dispose();
  }

  // Start the sync timer
  void _startSyncTimer() {
    _syncDuration.value = Duration.zero;
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _syncDuration.value += const Duration(seconds: 1);
    });
  }

  // Stop the sync timer
  void _stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Format duration as MM:SS
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  // Show sync options dialog
  void _showSyncDialog(BuildContext context, String syncType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sync $syncType'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose where to sync:'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Update Remote Server'),
                  onPressed: () {
                    Navigator.pop(context);
                    _performSync(context, syncType, isRemote: true);
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Update Local Data'),
                  onPressed: () {
                    Navigator.pop(context);
                    _performSync(context, syncType, isRemote: false);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }


  // Perform the actual sync operation
  void _performSync(BuildContext context, String syncType, {required bool isRemote}) async {
    // Start the sync timer
    _startSyncTimer();
    
    // Show loading dialog with timer
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Syncing...'),
              const SizedBox(height: 8),
              ValueListenableBuilder<Duration>(
                valueListenable: _syncDuration,
                builder: (context, duration, _) {
                  return Text(
                    _formatDuration(duration),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Close the loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        
        // Show success message with duration
        final duration = _syncDuration.value;
        _stopSyncTimer();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${isRemote ? 'Remote' : 'Local'} $syncType data synced successfully!'),
                Text(
                  'Sync completed in ${_formatDuration(duration)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // Handle any errors
      if (context.mounted) {
        Navigator.pop(context);
        _stopSyncTimer();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Compact Hero Header
          _buildCompactHeroHeader(context, size),

          // Main Content - Takes remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Quick Stats Row
                  _buildCompactStatsRow(context),

                  const SizedBox(height: 16),

                  // Management Sections - Split into two rows
                  Expanded(
                    child: Column(
                      children: [
                        // Farm Management Row
                        Expanded(
                          child: _buildCompactManagementRow(
                            context,
                            "Farm Management",
                            Icons.agriculture_outlined,
                            [
                              ActionButtonData(
                                icon: Icons.add_circle_outline,
                                title: "Add Farm",
                                color: theme.colorScheme.primary,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context){
                                      return const AddFarmScreen();
                                    })
                                  );
                                },
                              ),
                              ActionButtonData(
                                icon: Icons.history_outlined,
                                title: "History",
                                color: theme.colorScheme.secondary,
                                onTap: () {},
                              ),
                              ActionButtonData(
                                icon: Icons.sync_outlined,
                                title: "Sync",
                                color: Colors.green,
                                onTap: () => _showSyncDialog(context, 'Farms'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Farmer Management Row
                        Expanded(
                          child: _buildCompactManagementRow(
                            context,
                            "Farmer Management",
                            Icons.people_outline,
                            [
                              ActionButtonData(
                                icon: Icons.person_add_outlined,
                                title: "Add Farmer",
                                color: theme.colorScheme.primary,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context){
                                        return const AddFarmerScreen();
                                      })
                                  );
                                },
                              ),
                              ActionButtonData(
                                icon: Icons.people_outlined,
                                title: "History",
                                color: theme.colorScheme.secondary,
                                onTap: () {},
                              ),
                              ActionButtonData(
                                icon: Icons.cloud_sync_outlined,
                                title: "Sync",
                                color: Colors.orange,
                                onTap: () => _showSyncDialog(context, 'Farmers'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Quick Actions
                  // _buildQuickActionsRow(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeroHeader(BuildContext context, Size size) {
    final theme = Theme.of(context);

    return Container(
      height: 180, // Reduced from 280
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                color: theme.colorScheme.onPrimary.withOpacity(0.1),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.eco_outlined,
                      size: 28,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Exim Project",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Agricultural Management System",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatsRow(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactStatItem(context, "125", "Farms", Icons.agriculture),
          _buildDivider(context),
          _buildCompactStatItem(context, "342", "Farmers", Icons.people),
          _buildDivider(context),
          _buildCompactStatItem(context, "15", "Pending", Icons.sync_problem, isWarning: true),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem(BuildContext context, String value, String label, IconData icon, {bool isWarning = false}) {
    final theme = Theme.of(context);
    final color = isWarning ? Colors.orange : theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 1,
      height: 30,
      color: theme.colorScheme.outline.withOpacity(0.2),
    );
  }

  Widget _buildCompactManagementRow(
      BuildContext context,
      String title,
      IconData titleIcon,
      List<ActionButtonData> actions,
      ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  titleIcon,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons Row
          Expanded(
            child: Row(
              children: actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < actions.length - 1 ? 8 : 0,
                    ),
                    child: _buildCompactActionButton(context, action),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton(BuildContext context, ActionButtonData data) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: data.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: data.color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: data.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  data.icon,
                  size: 20,
                  color: data.color,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  data.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.flash_on_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            "Quick Actions",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          _buildQuickActionChip(context, "Export", Icons.download_outlined),
          const SizedBox(width: 8),
          _buildQuickActionChip(context, "Reports", Icons.analytics_outlined),
          const SizedBox(width: 8),
          _buildQuickActionChip(context, "Settings", Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButtonData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  ActionButtonData({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}

class BackgroundPatternPainter extends CustomPainter {
  final Color color;

  BackgroundPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}