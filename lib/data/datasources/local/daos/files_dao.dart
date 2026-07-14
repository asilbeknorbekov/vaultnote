import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../database.dart';
import '../tables.dart';

part 'files_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [FilesTable])
class FilesDao extends DatabaseAccessor<AppDatabase> with _$FilesDaoMixin {
  FilesDao(super.db);

  Future<List<FileEntity>> getAllFiles() {
    return (select(filesTable)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  Future<List<FileEntity>> getFilesForNote(String noteId) {
    return (select(filesTable)..where((t) => t.noteId.equals(noteId))).get();
  }

  Future<FileEntity?> getFileById(String id) {
    return (select(filesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertFile(FilesTableCompanion file) {
    return into(filesTable).insert(file);
  }

  Future<int> deleteFile(String id) {
    return (delete(filesTable)..where((t) => t.id.equals(id))).go();
  }
}
