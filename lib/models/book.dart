import 'package:hive/hive.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String author;
  
  @HiveField(3)
  final String filePath;
  
  @HiveField(4)
  final BookType type;
  
  @HiveField(5)
  final DateTime dateAdded;
  
  @HiveField(6)
  final String? coverImagePath;
  
  @HiveField(7)
  int lastPageRead;
  
  @HiveField(8)
  DateTime? lastReadDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.type,
    required this.dateAdded,
    this.coverImagePath,
    this.lastPageRead = 0,
    this.lastReadDate,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      filePath: map['filePath'] ?? '',
      type: BookType.values[map['type'] ?? 0],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded'] ?? 0),
      coverImagePath: map['coverImagePath'],
      lastPageRead: map['lastPageRead'] ?? 0,
      lastReadDate: map['lastReadDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastReadDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'filePath': filePath,
      'type': type.index,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'coverImagePath': coverImagePath,
      'lastPageRead': lastPageRead,
      'lastReadDate': lastReadDate?.millisecondsSinceEpoch,
    };
  }
}

@HiveType(typeId: 1)
enum BookType {
  @HiveField(0)
  pdf,
  @HiveField(1)
  epub,
}