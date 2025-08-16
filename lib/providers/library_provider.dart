import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '../models/book.dart';
import '../services/storage_service.dart';

class LibraryProvider extends ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  LibraryProvider() {
    loadBooks();
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();

    _books = StorageService.getAllBooks();
    _books.sort((a, b) => b.lastReadDate?.compareTo(a.lastReadDate ?? DateTime(0)) ?? 0);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBook() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = result.files.single;
        final filePath = file.path!;
        final fileName = path.basenameWithoutExtension(file.name);
        final extension = path.extension(file.name).toLowerCase();

        final BookType type = extension == '.pdf' ? BookType.pdf : BookType.epub;

        final book = Book(
          id: const Uuid().v4(),
          title: fileName,
          author: 'Unknown Author',
          filePath: filePath,
          type: type,
          dateAdded: DateTime.now(),
        );

        await StorageService.saveBook(book);
        await loadBooks();
      }
    } catch (e) {
      debugPrint('Error adding book: $e');
    }
  }

  Future<void> deleteBook(String bookId) async {
    await StorageService.deleteBook(bookId);
    await loadBooks();
  }

  Future<void> updateBookProgress(String bookId, int pageNumber) async {
    await StorageService.updateBookProgress(bookId, pageNumber);
    await loadBooks();
  }
}