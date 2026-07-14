import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../database.dart';
import '../tables.dart';

part 'notes_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [NotesTable])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  /// Get all active notes (not trashed, not archived) ordered by newest first
  Future<List<NoteEntity>> getActiveNotes() {
    return (select(notesTable)
          ..where((t) => t.isTrashed.equals(false) & t.isArchived.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get all pinned notes
  Future<List<NoteEntity>> getPinnedNotes() {
    return (select(notesTable)
          ..where((t) => t.isPinned.equals(true) & t.isTrashed.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get a specific note by ID
  Future<NoteEntity?> getNoteById(String id) {
    return (select(notesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Insert a new note
  Future<int> insertNote(NotesTableCompanion note) {
    return into(notesTable).insert(note);
  }

  /// Update an existing note
  Future<bool> updateNote(NotesTableCompanion note) {
    return update(notesTable).replace(note);
  }

  /// Move a note to trash
  Future<int> trashNote(String id) {
    return (update(notesTable)..where((t) => t.id.equals(id))).write(
      const NotesTableCompanion(
        isTrashed: Value(true),
        isPinned: Value(false),
      ),
    );
  }
  
  /// Delete a note permanently
  Future<int> deleteNotePermanently(String id) {
    return (delete(notesTable)..where((t) => t.id.equals(id))).go();
  }
}
