import 'package:hive/hive.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 2)
class Bookmark extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String bookId;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final int pageNumber;
  
  @HiveField(4)
  final DateTime dateCreated;
  
  @HiveField(5)
  final String? note;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.title,
    required this.pageNumber,
    required this.dateCreated,
    this.note,
  });
}