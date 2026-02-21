import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Result of an update availability check.
class UpdateCheckResult {
  final bool updateAvailable;
  final AppUpdateInfo? updateInfo;
  final String? error;

  const UpdateCheckResult._({
    required this.updateAvailable,
    this.updateInfo,
    this.error,
  });

  factory UpdateCheckResult.available(AppUpdateInfo info) =>
      UpdateCheckResult._(updateAvailable: true, updateInfo: info);

  factory UpdateCheckResult.notAvailable() =>
      UpdateCheckResult._(updateAvailable: false);

  factory UpdateCheckResult.failed(String error) =>
      UpdateCheckResult._(updateAvailable: false, error: error);
}

/// A service for managing Google Play In-App Updates.
///
/// Features:
/// - Single-invocation guard to prevent concurrent checks
/// - Cooldown period (default 24h) to avoid spamming the Play Store API
/// - Timeout on API calls to prevent hanging
/// - Only runs on Android
class InAppUpdateService {
  InAppUpdateService._();
  static final InAppUpdateService _instance = InAppUpdateService._();
  static InAppUpdateService get instance => _instance;

  /// Guard: true while a check is in progress.
  bool _isChecking = false;

  /// Timestamp of the last successful check.
  DateTime? _lastCheckTime;

  /// Minimum duration between consecutive update checks.
  static const Duration _checkCooldown = Duration(hours: 24);

  /// Timeout for the Play Store API call.
  static const Duration _apiTimeout = Duration(seconds: 10);

  /// Whether the cooldown has elapsed since the last check.
  bool get _isCooldownElapsed {
    if (_lastCheckTime == null) return true;
    return DateTime.now().difference(_lastCheckTime!) >= _checkCooldown;
  }

  /// Checks for an available update on Google Play.
  ///
  /// Returns [UpdateCheckResult.notAvailable] if:
  /// - Not running on Android
  /// - A check is already in progress (prevents re-entrant loops)
  /// - Cooldown has not elapsed since the last check
  ///
  /// Returns [UpdateCheckResult.failed] if the API call throws or times out.
  Future<UpdateCheckResult> checkForUpdate() async {
    // Only supported on Android
    if (!Platform.isAndroid) {
      return UpdateCheckResult.notAvailable();
    }

    // Prevent concurrent / re-entrant calls
    if (_isChecking) {
      debugPrint('[InAppUpdateService] Check already in progress, skipping.');
      return UpdateCheckResult.notAvailable();
    }

    // Cooldown guard: avoid hammering the API
    if (!_isCooldownElapsed) {
      debugPrint('[InAppUpdateService] Cooldown active, skipping check.');
      return UpdateCheckResult.notAvailable();
    }

    _isChecking = true;

    try {
      final info = await InAppUpdate.checkForUpdate().timeout(_apiTimeout);

      _lastCheckTime = DateTime.now();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        return UpdateCheckResult.available(info);
      }

      return UpdateCheckResult.notAvailable();
    } on TimeoutException {
      debugPrint('[InAppUpdateService] Update check timed out.');
      return UpdateCheckResult.failed('Update check timed out.');
    } catch (e) {
      debugPrint('[InAppUpdateService] Update check failed: $e');
      return UpdateCheckResult.failed(e.toString());
    } finally {
      _isChecking = false;
    }
  }

  /// Starts a flexible (background) update flow.
  ///
  /// Returns `true` if the update was started successfully.
  Future<bool> startFlexibleUpdate() async {
    try {
      await InAppUpdate.startFlexibleUpdate();
      return true;
    } catch (e) {
      debugPrint('[InAppUpdateService] Flexible update failed: $e');
      return false;
    }
  }

  /// Completes a previously downloaded flexible update (triggers app restart).
  Future<bool> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
      return true;
    } catch (e) {
      debugPrint('[InAppUpdateService] Complete flexible update failed: $e');
      return false;
    }
  }

  /// Triggers an immediate (blocking) update flow managed by the Play Store.
  Future<bool> performImmediateUpdate() async {
    try {
      final result = await InAppUpdate.performImmediateUpdate();
      return result == AppUpdateResult.success;
    } catch (e) {
      debugPrint('[InAppUpdateService] Immediate update failed: $e');
      return false;
    }
  }
}
