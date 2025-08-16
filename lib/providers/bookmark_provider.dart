import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/bookmark.dart';
import '../services/storage_service.dart';

class BookmarkProvider extends ChangeNotifier {
  List<Bookmark> _bookmarks = [];

  List<Bookmark> get bookmarks => _bookmarks;

  Future<void> loadBookmarks(String bookId) async {
    _bookmarks = StorageService.getBookmarksForBook(bookId);
    notifyListeners();
  }

  Future<void> addBookmark(String bookId, String title, int pageNumber, {String? note}) async {
    final bookmark = Bookmark(
      id: const Uuid().v4(),
      bookId: bookId,
      title: title,
      pageNumber: pageNumber,
      dateCreated: DateTime.now(),
      note: note,
    );

    await StorageService.saveBookmark(bookmark);
    await loadBookmarks(bookId);
  }

  Future<void> deleteBookmark(String bookmarkId, String bookId) async {
    await StorageService.deleteBookmark(bookmarkId);
    await loadBookmarks(bookId);
  }

  bool isBookmarked(String bookId, int pageNumber) {
    return _bookmarks.any((bookmark) => 
        bookmark.bookId == bookId && bookmark.pageNumber == pageNumber);
  }
}