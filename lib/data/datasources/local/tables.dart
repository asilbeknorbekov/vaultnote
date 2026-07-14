import 'package:drift/drift.dart';

@DataClassName('NoteEntity')
class NotesTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()(); // Plain text for fast searching
  TextColumn get contentEncrypted => text()(); // The actual note body, AES-256 encrypted
  TextColumn get summaryEncrypted => text().nullable()(); // AI generated summary, encrypted
  TextColumn get tags => text().nullable()(); // Comma separated tags, plain text for querying
  IntColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get isPinned => boolean().withDefault(const Constant(false))();
  IntColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get isTrashed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FileEntity')
class FilesTable extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().nullable().references(NotesTable, #id)(); // Can be attached to a note or standalone
  TextColumn get fileName => text()();
  TextColumn get fileType => text()(); // e.g., 'pdf', 'png', 'docx'
  TextColumn get localPath => text()(); // Path to the encrypted file on disk
  IntColumn get sizeBytes => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
