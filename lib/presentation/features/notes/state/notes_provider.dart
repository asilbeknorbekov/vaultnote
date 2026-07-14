import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../domain/entities/note.dart';
import '../../../../domain/repositories/notes_repository.dart';

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return getIt<NotesRepository>();
});

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(() {
  return NotesNotifier();
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  late final NotesRepository _repository;

  @override
  Future<List<Note>> build() async {
    _repository = ref.watch(notesRepositoryProvider);
    return _repository.getActiveNotes();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getActiveNotes());
  }

  Future<void> saveNote(Note note) async {
    // Optimistic UI update
    final previousState = state;
    if (state.hasValue) {
      final list = List<Note>.from(state.value!);
      final index = list.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        list[index] = note;
      } else {
        list.insert(0, note); // Prepend new note
      }
      state = AsyncValue.data(list);
    }

    try {
      await _repository.saveNote(note);
      // Re-fetch to ensure exact ordering
      await refresh();
    } catch (e, st) {
      state = previousState; // Rollback
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> trashNote(String id) async {
    final previousState = state;
    if (state.hasValue) {
      final list = List<Note>.from(state.value!);
      list.removeWhere((n) => n.id == id);
      state = AsyncValue.data(list);
    }

    try {
      await _repository.trashNote(id);
    } catch (e, st) {
      state = previousState;
      state = AsyncValue.error(e, st);
    }
  }
}
