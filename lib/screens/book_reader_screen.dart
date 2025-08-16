import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:epub_view/epub_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../providers/bookmark_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/bookmarks_drawer.dart';
import 'dart:io';

class BookReaderScreen extends StatefulWidget {
  final Book book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  late PdfViewerController _pdfController;
  late EpubController _epubController;
  bool _isBookmarked = false;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _epubController = EpubController();
    
    // Load bookmarks for this book
    context.read<BookmarkProvider>().loadBookmarks(widget.book.id);
    
    // Jump to last read page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.book.lastPageRead > 0) {
        if (widget.book.type == BookType.pdf) {
          _pdfController.jumpToPage(widget.book.lastPageRead);
        }
      }
    });
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _epubController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? Colors.amber : null,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      drawer: BookmarksDrawer(
        bookId: widget.book.id,
        onBookmarkTap: (pageNumber) {
          if (widget.book.type == BookType.pdf) {
            _pdfController.jumpToPage(pageNumber);
          }
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.book.type == BookType.pdf
                ? _buildPdfViewer()
                : _buildEpubViewer(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    return SfPdfViewer.file(
      File(widget.book.filePath),
      controller: _pdfController,
      onPageChanged: (details) {
        setState(() {
          _currentPage = details.newPageNumber;
          _isBookmarked = context.read<BookmarkProvider>()
              .isBookmarked(widget.book.id, _currentPage);
        });
        
        // Update reading progress
        context.read<LibraryProvider>()
            .updateBookProgress(widget.book.id, _currentPage);
      },
      onDocumentLoaded: (details) {
        setState(() {
          _totalPages = details.document.pages.count;
        });
      },
    );
  }

  Widget _buildEpubViewer() {
    return EpubView(
      builders: EpubViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(
          textStyle: TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),
        chapterDividerBuilder: (_) => const Divider(),
      ),
      controller: _epubController,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: _currentPage > 1 ? _previousPage : null,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_totalPages > 0)
                  LinearProgressIndicator(
                    value: _currentPage / _totalPages,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _currentPage < _totalPages ? _nextPage : null,
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    if (widget.book.type == BookType.pdf) {
      _pdfController.previousPage();
    }
  }

  void _nextPage() {
    if (widget.book.type == BookType.pdf) {
      _pdfController.nextPage();
    }
  }

  void _toggleBookmark() {
    final bookmarkProvider = context.read<BookmarkProvider>();
    
    if (_isBookmarked) {
      // Find and remove bookmark
      final bookmark = bookmarkProvider.bookmarks
          .where((b) => b.bookId == widget.book.id && b.pageNumber == _currentPage)
          .firstOrNull;
      
      if (bookmark != null) {
        bookmarkProvider.deleteBookmark(bookmark.id, widget.book.id);
      }
    } else {
      // Add bookmark
      bookmarkProvider.addBookmark(
        widget.book.id,
        'Page $_currentPage',
        _currentPage,
      );
    }
    
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  void _showSearchDialog() {
    if (widget.book.type == BookType.pdf) {
      _pdfController.openSearchToolbar();
    } else {
      // For EPUB, show a custom search dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Search'),
          content: const TextField(
            decoration: InputDecoration(
              hintText: 'Enter search term...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement EPUB search functionality
              },
              child: const Text('Search'),
            ),
          ],
        ),
      );
    }
  }
}