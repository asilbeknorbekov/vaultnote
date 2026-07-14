import '../entities/note.dart';

abstract class NotesRepository {
  Future<List<Note>> getActiveNotes();
  Future<List<Note>> getPinnedNotes();
  Future<Note?> getNoteById(String id);
  Future<void> saveNote(Note note);
  Future<void> trashNote(String id);
  Future<void> deleteNotePermanently(String id);
}
