import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/secure_file_storage.dart';
import '../../../domain/entities/vault_file.dart';
import '../../../domain/repositories/files_repository.dart';
import '../../datasources/local/daos/files_dao.dart';
import '../../datasources/local/database.dart';

@LazySingleton(as: FilesRepository)
class FilesRepositoryImpl implements FilesRepository {
  final FilesDao _filesDao;
  final SecureFileStorage _secureFileStorage;

  FilesRepositoryImpl(this._filesDao, this._secureFileStorage);

  VaultFile _mapToEntity(FileEntity dbFile) {
    return VaultFile(
      id: dbFile.id,
      noteId: dbFile.noteId,
      fileName: dbFile.fileName,
      fileType: dbFile.fileType,
      localPath: dbFile.localPath,
      sizeBytes: dbFile.sizeBytes,
      createdAt: dbFile.createdAt,
    );
  }

  @override
  Future<List<VaultFile>> getAllFiles() async {
    final dbFiles = await _filesDao.getAllFiles();
    return dbFiles.map(_mapToEntity).toList();
  }

  @override
  Future<List<VaultFile>> getFilesForNote(String noteId) async {
    final dbFiles = await _filesDao.getFilesForNote(noteId);
    return dbFiles.map(_mapToEntity).toList();
  }

  @override
  Future<VaultFile> saveFile({
    required String fileName,
    required String fileType,
    required Uint8List rawBytes,
    String? noteId,
  }) async {
    final fileId = const Uuid().v4();
    
    // 1. Write the encrypted file to disk securely
    final localPath = await _secureFileStorage.saveFile(fileId, rawBytes, fileType);
    
    // 2. Save metadata to SQLite
    final createdAt = DateTime.now();
    final companion = FilesTableCompanion(
      id: Value(fileId),
      noteId: Value(noteId),
      fileName: Value(fileName),
      fileType: Value(fileType),
      localPath: Value(localPath),
      sizeBytes: Value(rawBytes.length),
      createdAt: Value(createdAt),
    );
    
    await _filesDao.insertFile(companion);
    
    return VaultFile(
      id: fileId,
      noteId: noteId,
      fileName: fileName,
      fileType: fileType,
      localPath: localPath,
      sizeBytes: rawBytes.length,
      createdAt: createdAt,
    );
  }

  @override
  Future<Uint8List> getFileBytes(String fileId) async {
    final dbFile = await _filesDao.getFileById(fileId);
    if (dbFile == null) throw Exception('File not found in database');
    
    // Reads from disk and decrypts
    return await _secureFileStorage.readFile(dbFile.localPath);
  }

  @override
  Future<void> deleteFile(String fileId) async {
    final dbFile = await _filesDao.getFileById(fileId);
    if (dbFile != null) {
      await _secureFileStorage.deleteFile(dbFile.localPath);
      await _filesDao.deleteFile(fileId);
    }
  }
}
