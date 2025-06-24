import 'package:flutter/material.dart';

class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final int itemsPerPage;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ValueChanged<int>? onPageChanged;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemsPerPage = 10,
    this.onPageChanged,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  int _currentPage = 0;

  int get totalPages => widget.items.isEmpty
      ? 1
      : (widget.items.length / widget.itemsPerPage).ceil();

  List<T> get _currentItems {
    final total = widget.items.length;
    final totalPagesLocal = totalPages;

    if (total == 0 || totalPagesLocal == 0) return [];

    final safePage = _currentPage.clamp(0, totalPagesLocal - 1);
    final start = safePage * widget.itemsPerPage;
    final end = (start + widget.itemsPerPage).clamp(start, total);

    if (start >= total || start >= end) return [];

    return widget.items.sublist(start, end);
  }

  void _goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      setState(() => _currentPage = page);
      widget.onPageChanged?.call(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPage >= totalPages && totalPages > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentPage = 0;
          widget.onPageChanged?.call(0);
        });
      });
      return const SizedBox();
    }

    final currentItems = _currentItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentItems.length,
          itemBuilder: (context, index) {
            return widget.itemBuilder(context, currentItems[index]);
          },
        ),
        const SizedBox(height: 12),
        if (totalPages > 1) _buildPaginationControls(context),
      ],
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    const double spacing = 16; // Khoảng cách giữa các số
    const double minTouchTarget =
        44; // Vùng touch tối thiểu theo Material Design

    List<Widget> pageButtons = [];

    Widget addPageNumber(int page) {
      final isActive = page == _currentPage;
      return GestureDetector(
        onTap: () => _goToPage(page),
        child: Container(
          constraints: const BoxConstraints(
              minWidth: minTouchTarget, minHeight: minTouchTarget),
          alignment: Alignment.center,
          child: Text(
            '${page + 1}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.black87,
            ),
          ),
        ),
      );
    }

    // Logic hiển thị tối đa 3 số
    if (totalPages <= 3) {
      // Nếu có ≤ 3 trang: hiển thị tất cả
      for (int i = 0; i < totalPages; i++) {
        pageButtons.add(addPageNumber(i));
      }
    } else {
      // Nếu có > 3 trang: hiển thị theo pattern
      if (_currentPage <= 1) {
        // Ở đầu: 1 2 ... last
        pageButtons.add(addPageNumber(0));
        pageButtons.add(addPageNumber(1));
        pageButtons.add(_buildEllipsis());
        pageButtons.add(addPageNumber(totalPages - 1));
      } else if (_currentPage >= totalPages - 2) {
        // Ở cuối: 1 ... (last-1) last
        pageButtons.add(addPageNumber(0));
        pageButtons.add(_buildEllipsis());
        pageButtons.add(addPageNumber(totalPages - 2));
        pageButtons.add(addPageNumber(totalPages - 1));
      } else {
        // Ở giữa: 1 ... current ... last
        pageButtons.add(addPageNumber(0));
        pageButtons.add(_buildEllipsis());
        pageButtons.add(addPageNumber(_currentPage));
        pageButtons.add(_buildEllipsis());
        pageButtons.add(addPageNumber(totalPages - 1));
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nút về đầu
            _buildArrowButton(Icons.first_page, () => _goToPage(0),
                enabled: _currentPage > 0),
            const SizedBox(width: 8),

            // Nút về trước
            _buildArrowButton(
                Icons.chevron_left, () => _goToPage(_currentPage - 1),
                enabled: _currentPage > 0),
            const SizedBox(width: 16),

            // Các số trang
            Wrap(
              spacing: spacing,
              alignment: WrapAlignment.center,
              children: pageButtons,
            ),

            const SizedBox(width: 16),

            // Nút tiếp theo
            _buildArrowButton(
                Icons.chevron_right, () => _goToPage(_currentPage + 1),
                enabled: _currentPage < totalPages - 1),
            const SizedBox(width: 8),

            // Nút về cuối
            _buildArrowButton(Icons.last_page, () => _goToPage(totalPages - 1),
                enabled: _currentPage < totalPages - 1),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed,
      {bool enabled = true}) {
    return SizedBox(
      height: 36,
      width: 36,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: enabled ? onPressed : null,
        padding: EdgeInsets.zero,
        iconSize: 20,
        color: enabled ? Colors.black87 : Colors.grey,
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      alignment: Alignment.center,
      child: const Text(
        '...',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}
