import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../domain/entities/vault_file.dart';
import '../../../../domain/repositories/files_repository.dart';

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  return getIt<FilesRepository>();
});

final filesProvider = AsyncNotifierProvider<FilesNotifier, List<VaultFile>>(() {
  return FilesNotifier();
});

class FilesNotifier extends AsyncNotifier<List<VaultFile>> {
  late final FilesRepository _repository;

  @override
  Future<List<VaultFile>> build() async {
    _repository = ref.watch(filesRepositoryProvider);
    return _repository.getAllFiles();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllFiles());
  }

  Future<VaultFile?> saveFile(String fileName, String fileType, Uint8List bytes, {String? noteId}) async {
    try {
      final newFile = await _repository.saveFile(
        fileName: fileName,
        fileType: fileType,
        rawBytes: bytes,
        noteId: noteId,
      );
      
      // Update state
      if (state.hasValue) {
        final list = List<VaultFile>.from(state.value!);
        list.insert(0, newFile);
        state = AsyncValue.data(list);
      }
      return newFile;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> deleteFile(String fileId) async {
    try {
      await _repository.deleteFile(fileId);
      if (state.hasValue) {
        final list = List<VaultFile>.from(state.value!);
        list.removeWhere((f) => f.id == fileId);
        state = AsyncValue.data(list);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
