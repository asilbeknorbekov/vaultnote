import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../../../core/security/encryption_service.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/repositories/notes_repository.dart';
import '../../datasources/local/daos/notes_dao.dart';
import '../../datasources/local/database.dart';

@LazySingleton(as: NotesRepository)
class NotesRepositoryImpl implements NotesRepository {
  final NotesDao _notesDao;
  final EncryptionService _encryptionService;

  NotesRepositoryImpl(this._notesDao, this._encryptionService);

  Note _mapToEntity(NoteEntity dbNote) {
    return Note(
      id: dbNote.id,
      title: dbNote.title,
      // Decrypt content when reading from DB
      content: _encryptionService.decryptText(dbNote.contentEncrypted),
      summary: dbNote.summaryEncrypted != null 
          ? _encryptionService.decryptText(dbNote.summaryEncrypted!)
          : null,
      tags: dbNote.tags?.split(',').where((t) => t.isNotEmpty).toList() ?? [],
      isFavorite: dbNote.isFavorite,
      isPinned: dbNote.isPinned,
      isArchived: dbNote.isArchived,
      isTrashed: dbNote.isTrashed,
      createdAt: dbNote.createdAt,
      updatedAt: dbNote.updatedAt,
    );
  }

  @override
  Future<List<Note>> getActiveNotes() async {
    final dbNotes = await _notesDao.getActiveNotes();
    return dbNotes.map(_mapToEntity).toList();
  }

  @override
  Future<List<Note>> getPinnedNotes() async {
    final dbNotes = await _notesDao.getPinnedNotes();
    return dbNotes.map(_mapToEntity).toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final dbNote = await _notesDao.getNoteById(id);
    if (dbNote == null) return null;
    return _mapToEntity(dbNote);
  }

  @override
  Future<void> saveNote(Note note) async {
    final companion = NotesTableCompanion(
      id: Value(note.id),
      title: Value(note.title),
      // Encrypt content before saving to DB
      contentEncrypted: Value(_encryptionService.encryptText(note.content)),
      summaryEncrypted: Value(note.summary != null ? _encryptionService.encryptText(note.summary!) : null),
      tags: Value(note.tags.join(',')),
      isFavorite: Value(note.isFavorite),
      isPinned: Value(note.isPinned),
      isArchived: Value(note.isArchived),
      isTrashed: Value(note.isTrashed),
      createdAt: Value(note.createdAt),
      updatedAt: Value(note.updatedAt),
    );

    final existing = await _notesDao.getNoteById(note.id);
    if (existing == null) {
      await _notesDao.insertNote(companion);
    } else {
      await _notesDao.updateNote(companion);
    }
  }

  @override
  Future<void> trashNote(String id) async {
    await _notesDao.trashNote(id);
  }

  @override
  Future<void> deleteNotePermanently(String id) async {
    await _notesDao.deleteNotePermanently(id);
  }
}
