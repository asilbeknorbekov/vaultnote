import 'package:equatable/equatable.dart';

class VaultFile extends Equatable {
  final String id;
  final String? noteId; // Null if it's a standalone file in the vault
  final String fileName;
  final String fileType; // e.g., 'pdf', 'png', 'mp3'
  final String localPath; // Absolute path to the encrypted .enc file on disk
  final int sizeBytes;
  final DateTime createdAt;

  const VaultFile({
    required this.id,
    this.noteId,
    required this.fileName,
    required this.fileType,
    required this.localPath,
    required this.sizeBytes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        noteId,
        fileName,
        fileType,
        localPath,
        sizeBytes,
        createdAt,
      ];
}
