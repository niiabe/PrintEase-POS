import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/backup_service.dart';

class BackupState {
  final bool isLoading;
  final String? message;
  final bool isError;

  const BackupState({
    this.isLoading = false,
    this.message,
    this.isError = false,
  });

  BackupState copyWith({
    bool? isLoading,
    String? message,
    bool? isError,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      isError: isError ?? this.isError,
    );
  }
}

class BackupNotifier extends StateNotifier<BackupState> {
  final BackupService _service;

  BackupNotifier(this._service) : super(const BackupState());

  Future<void> exportBackup() async {
    state = state.copyWith(isLoading: true, message: null);
    final result = await _service.exportBackup();
    state = state.copyWith(
      isLoading: false,
      message: result.message,
      isError: !result.success,
    );
  }

  Future<void> importBackup() async {
    state = state.copyWith(isLoading: true, message: null);
    final result = await _service.importBackup();
    state = state.copyWith(
      isLoading: false,
      message: result.message,
      isError: !result.success,
    );
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}

final backupProvider =
    StateNotifierProvider<BackupNotifier, BackupState>((ref) {
  return BackupNotifier(BackupService());
});
