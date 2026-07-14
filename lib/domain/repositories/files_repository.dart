import 'dart:typed_data';
import '../entities/vault_file.dart';

abstract class FilesRepository {
  /// Retrieve all files stored in the vault
  Future<List<VaultFile>> getAllFiles();

  /// Retrieve all files attached to a specific note
  Future<List<VaultFile>> getFilesForNote(String noteId);

  /// Saves a file into the secure vault and records its metadata
  Future<VaultFile> saveFile({
    required String fileName,
    required String fileType,
    required Uint8List rawBytes,
    String? noteId,
  });

  /// Reads a file from the vault and decrypts its contents into memory
  Future<Uint8List> getFileBytes(String fileId);

  /// Deletes a file permanently from the disk and the database
  Future<void> deleteFile(String fileId);
}
