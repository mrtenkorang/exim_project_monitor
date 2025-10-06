import 'package:exim_project_monitor/core/models/user_model.dart';
import 'package:exim_project_monitor/core/services/api/api.dart';
import 'package:exim_project_monitor/features/screen_wrapper/screen_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/cache_service/cache_service.dart';
import '../version/version_check_screen.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  _SyncPageState createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isSyncing = false;
  int _retryCount = 0;
  User? userInfo;
  final Set<int> _failedSteps = {};
  final Map<int, String> _syncStatusMessages = {};
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _versionCheckComplete = false;

  final List<SyncStep> _syncSteps = [
    SyncStep(
      title: "App Version",
      function: APIService().checkAppVersion,
      isVersionCheck: true,
    ),
    SyncStep(
      title: "Districts Data",
      function: APIService().fetchAndSaveDistricts,
    ),
    SyncStep(
      title: "Regions Data",
      function: APIService().fetchAndSaveRegions,
    ),
    SyncStep(
      title: "Projects Data",
      function: APIService().fetchAndSaveProjects,
    ),
    SyncStep(
      title: "Farmer & Farms Data",
      function: APIService().fetchFarmersFromServer,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSync();
    });
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startSync({bool retryOnlyFailed = false}) async {
    // Check internet connection
    // if (!await ConnectionVerify.connectionIsAvailable()) {
    //   final isInternet = await ConnectionVerify.checkConnectionQuality();
    //   debugPrint("Internet: $isInternet");
    //   Get.offAll(() => Wrapper());
    //   return;
    // }

    setState(() {
      _isSyncing = true;
      if (!retryOnlyFailed) {
        _currentStep = 0;
        _failedSteps.clear();
        _syncStatusMessages.clear();
        _retryCount = 0;
        _versionCheckComplete = false;
      }
      _animationController.reset();
      _animationController.forward();
    });

    // Prepare steps to sync
    List<int> stepsToSync = [];
    if (retryOnlyFailed) {
      stepsToSync = _failedSteps.toList();
    } else {
      stepsToSync = List.generate(_syncSteps.length, (index) => index);
    }

    stepsToSync.sort();

    // Process sync steps
    for (int index in stepsToSync) {
      if (!mounted) return;

      final step = _syncSteps[index];

      setState(() {
        _currentStep = index;
        _syncStatusMessages[index] = "Starting...";
      });

      try {
        setState(() {
          _syncStatusMessages[index] = "Syncing...";
        });

        final result = await step.function();

        // Handle version check separately
        if (step.isVersionCheck) {
          await _handleVersionCheck(result, index);
          if (!_versionCheckComplete) {
            // Version check failed, stop sync process
            return;
          }
        } else {
          // Regular sync step
          if (mounted) {
            setState(() {
              _syncStatusMessages[index] = "Success";
              _failedSteps.remove(index);
            });
          }
        }
      } catch (e, stackTrace) {
        debugPrint("Sync error: $e\nStack trace: $stackTrace");
        await _handleSyncError(e, index, step.title);
      }

      // Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 200));
    }

    await _completeSyncProcess();
  }

  Future<void> _handleVersionCheck(dynamic result, int index) async {
    debugPrint("Version check result: ${result['status']}");

    if (result['status'] == false && result['success'] == true) {
      // Version check failed - update required
      if (mounted) {
        setState(() {
          _syncStatusMessages[index] = "Update required";
          _isSyncing = false;
          _versionCheckComplete = false;
        });
      }
      // Navigate to version check screen
      Get.offAll(() => const VersionCheckScreen());
    } else {
      // Version check passed or non-blocking error
      if (mounted) {
        setState(() {
          _syncStatusMessages[index] = result['message'] ?? 'Version check complete';
          _versionCheckComplete = true;
        });
      }
    }
  }

  Future<void> _handleSyncError(dynamic error, int index, String stepTitle) async {
    debugPrint('Error during $stepTitle sync: $error');

    String errorMessage = "Failed";
    if (error is String) {
      errorMessage = error;
    } else if (error.toString().isNotEmpty) {
      // Get the first line of error message for cleaner display
      errorMessage = error.toString().split('\n').first;
    }

    if (mounted) {
      setState(() {
        _syncStatusMessages[index] = errorMessage;
        _failedSteps.add(index);
      });
    }
  }

  Future<void> _completeSyncProcess() async {
    if (!mounted) return;

    setState(() {
      _isSyncing = false;
    });

    // Fetch user info regardless of sync result
    // await fetchUserInfo();

    if (_failedSteps.isEmpty) {
      // All syncs successful
      _navigateToHome();
    } else if (_retryCount < 2) {
      // Some failed, retries available
      _retryCount++;
    } else {
      // Max retries reached, continue anyway
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Get.offAll(() => const ScreenWrapper());
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        title: Text(
          "Data Synchronization",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
          onPressed: () => Get.offAll(() => ScreenWrapper()),
        ),
      ),
      body: Column(
        children: [
          if (_isSyncing)
            LinearProgressIndicator(
              value: _currentStep / _syncSteps.length,
              backgroundColor: theme.colorScheme.secondary,
              color: theme.primaryColor,
              minHeight: 4,
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _animation.value)),
                      child: child,
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sync,
                              color: theme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Sync Progress",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              "${_currentStep + 1}/${_syncSteps.length}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _syncSteps.length,
                            itemBuilder: (context, index) {
                              final step = _syncSteps[index];
                              final isFailed = _failedSteps.contains(index);
                              final isSynced = _syncStatusMessages[index] == "Success";
                              final isSyncing = _syncStatusMessages[index] == "Syncing...";
                              final isCurrent = index == _currentStep && _isSyncing;
                              final isPending = _syncStatusMessages[index] == null ||
                                  _syncStatusMessages[index] == "Starting...";

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isFailed
                                      ? theme.colorScheme.error.withOpacity(0.1)
                                      : isSynced
                                      ? Colors.green.withOpacity(0.1)
                                      : isCurrent
                                      ? theme.primaryColor.withOpacity(0.05)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isFailed
                                        ? theme.colorScheme.error.withOpacity(0.3)
                                        : isSynced
                                        ? Colors.green.withOpacity(0.3)
                                        : isCurrent
                                        ? theme.primaryColor.withOpacity(0.3)
                                        : theme.colorScheme.outline.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Status Icon
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isFailed
                                            ? theme.colorScheme.error
                                            : isSynced
                                            ? Colors.green
                                            : isCurrent
                                            ? theme.primaryColor
                                            : theme.colorScheme.outline.withOpacity(0.3),
                                      ),
                                      child: Center(
                                        child: isCurrent && !isFailed
                                            ? SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                        )
                                            : Icon(
                                          isFailed
                                              ? Icons.error_outline
                                              : isSynced
                                              ? Icons.check
                                              : Icons.circle_outlined,
                                          color: theme.colorScheme.onPrimary,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            step.title,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          if (_syncStatusMessages[index] != null &&
                                              _syncStatusMessages[index] != "Success")
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                _syncStatusMessages[index]!,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: isFailed
                                                      ? theme.colorScheme.error
                                                      : theme.colorScheme.onSurface.withOpacity(0.7),
                                                  fontStyle: isFailed ? FontStyle.italic : FontStyle.normal,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Progress indicator for current step
                                    if (isCurrent && !isFailed)
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            theme.primaryColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Retry/Continue Section
          if (_failedSteps.isNotEmpty && _retryCount < 2 && !_isSyncing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, size: 20),
                      label: Text(
                        "Retry Failed (${2 - _retryCount} ${_retryCount == 1 ? 'attempt' : 'attempts'} left)",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _startSync(retryOnlyFailed: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.arrow_forward, size: 20),
                      label: const Text(
                        "Continue Anyway",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        side: BorderSide(color: theme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _navigateToHome,
                    ),
                  ),
                ],
              ),
            ),
          // Continue button when max retries reached or only version check failed
          if ((_failedSteps.isNotEmpty && _retryCount >= 2) ||
              (_failedSteps.length == 1 && _failedSteps.contains(0)) && !_isSyncing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  label: const Text(
                    "Continue to App",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _navigateToHome,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SyncStep {
  final String title;
  final Future<dynamic> Function() function;
  final bool isVersionCheck;

  SyncStep({
    required this.title,
    required this.function,
    this.isVersionCheck = false,
  });
}