import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content; // Plain text in memory, encrypted in DB
  final String? summary; // AI summary
  final List<String> tags;
  final bool isFavorite;
  final bool isPinned;
  final bool isArchived;
  final bool isTrashed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.summary,
    required this.tags,
    this.isFavorite = false,
    this.isPinned = false,
    this.isArchived = false,
    this.isTrashed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? title,
    String? content,
    String? summary,
    List<String>? tags,
    bool? isFavorite,
    bool? isPinned,
    bool? isArchived,
    bool? isTrashed,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isTrashed: isTrashed ?? this.isTrashed,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        summary,
        tags,
        isFavorite,
        isPinned,
        isArchived,
        isTrashed,
        createdAt,
        updatedAt,
      ];
}
