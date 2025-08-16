import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/bookmark.dart';

class StorageService {
  static const String _booksBoxName = 'books';
  static const String _bookmarksBoxName = 'bookmarks';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(BookTypeAdapter());
    Hive.registerAdapter(BookmarkAdapter());
    
    // Open boxes
    await Hive.openBox<Book>(_booksBoxName);
    await Hive.openBox<Bookmark>(_bookmarksBoxName);
  }

  // Books operations
  static Box<Book> get _booksBox => Hive.box<Book>(_booksBoxName);
  
  static Future<void> saveBook(Book book) async {
    await _booksBox.put(book.id, book);
  }

  static List<Book> getAllBooks() {
    return _booksBox.values.toList();
  }

  static Book? getBook(String id) {
    return _booksBox.get(id);
  }

  static Future<void> deleteBook(String id) async {
    await _booksBox.delete(id);
    // Also delete related bookmarks
    final bookmarks = getBookmarksForBook(id);
    for (final bookmark in bookmarks) {
      await deleteBookmark(bookmark.id);
    }
  }

  static Future<void> updateBookProgress(String bookId, int pageNumber) async {
    final book = getBook(bookId);
    if (book != null) {
      book.lastPageRead = pageNumber;
      book.lastReadDate = DateTime.now();
      await book.save();
    }
  }

  // Bookmarks operations
  static Box<Bookmark> get _bookmarksBox => Hive.box<Bookmark>(_bookmarksBoxName);

  static Future<void> saveBookmark(Bookmark bookmark) async {
    await _bookmarksBox.put(bookmark.id, bookmark);
  }

  static List<Bookmark> getAllBookmarks() {
    return _bookmarksBox.values.toList();
  }

  static List<Bookmark> getBookmarksForBook(String bookId) {
    return _bookmarksBox.values
        .where((bookmark) => bookmark.bookId == bookId)
        .toList()
      ..sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
  }

  static Future<void> deleteBookmark(String id) async {
    await _bookmarksBox.delete(id);
  }

  static Future<void> close() async {
    await Hive.close();
  }
}