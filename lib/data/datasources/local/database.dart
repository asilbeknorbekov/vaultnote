import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:injectable/injectable.dart';
import 'tables.dart';

part 'database.g.dart'; // Drift will generate this

@lazySingleton
@DriftDatabase(tables: [NotesTable, FilesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vaultnote.sqlite'));
    // Since we're using NativeDatabase and haven't imported flutter_sqlite_libs yet, 
    // we use a simple native backend. Production might switch to SQLCipher if we encrypt the whole DB.
    // For Phase 1, we rely on our EncryptionService for note content and files.
    return NativeDatabase.createInBackground(file);
  });
}
