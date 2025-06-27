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
  late final ScrollController _scrollController;
  int _currentPage = 0;

  int get totalPages =>
      widget.items.isEmpty ? 1 : (widget.items.length / widget.itemsPerPage).ceil();

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page >= 0 && page < totalPages) {
      setState(() => _currentPage = page);
      widget.onPageChanged?.call(page);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showPageInputDialog(BuildContext context) {
    final TextEditingController _inputController =
    TextEditingController(text: (_currentPage + 1).toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nhập số trang'),
          content: TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Từ 1 đến $totalPages',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final input = int.tryParse(_inputController.text);
                if (input == null || input < 1 || input > totalPages) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vui lòng nhập số từ 1 đến $totalPages')),
                  );
                  return;
                }
                Navigator.pop(context);
                _goToPage(input - 1);
              },
              child: const Text('Đi đến'),
            ),
          ],
        );
      },
    );
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: _currentItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              widget.itemBuilder(context, _currentItems[index]),
        ),
        const SizedBox(height: 12),
        if (totalPages > 1) _buildPaginationControls(context),
      ],
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double buttonWidth = 44;
        const double spacing = 4;
        const double arrowButtonsWidth = buttonWidth * 4 + spacing * 6;

        final double availableWidth = constraints.maxWidth - arrowButtonsWidth;
        final int rawButtons = (availableWidth / (buttonWidth + spacing)).floor();
        final int maxPageButtons = rawButtons.clamp(1, totalPages);

        List<Widget> pageButtons = [];

        void addPageButton(int page) {
          final isActive = page == _currentPage;
          pageButtons.add(
            SizedBox(
              height: 36,
              width: buttonWidth,
              child: OutlinedButton(
                onPressed: () => _goToPage(page),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isActive ? Colors.blue : null,
                  foregroundColor: isActive ? Colors.white : null,
                  padding: EdgeInsets.zero,
                ),
                child: Text('${page + 1}'),
              ),
            ),
          );
        }

        int start = 0;
        int end = totalPages - 1;

        if (totalPages > maxPageButtons) {
          start = (_currentPage - (maxPageButtons ~/ 2))
              .clamp(0, totalPages - maxPageButtons);
          end = (start + maxPageButtons - 1).clamp(0, totalPages - 1);
        }

        if (start > 0) {
          addPageButton(0);
          if (start > 1) pageButtons.add(_buildEllipsis());
        }

        for (int i = start; i <= end; i++) {
          addPageButton(i);
        }

        if (end < totalPages - 1) {
          if (end < totalPages - 2) pageButtons.add(_buildEllipsis());
          addPageButton(totalPages - 1);
        }

        return Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _buildIconButton(Icons.first_page, () => _goToPage(0),
                    enabled: _currentPage > 0),
                _buildIconButton(Icons.chevron_left, () => _goToPage(_currentPage - 1),
                    enabled: _currentPage > 0),
                ...pageButtons,
                _buildIconButton(Icons.chevron_right, () => _goToPage(_currentPage + 1),
                    enabled: _currentPage < totalPages - 1),
                _buildIconButton(Icons.last_page, () => _goToPage(totalPages - 1),
                    enabled: _currentPage < totalPages - 1),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Trang: "),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text("Nhập số"),
                  onPressed: () => _showPageInputDialog(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed,
      {bool enabled = true}) {
    return SizedBox(
      height: 36,
      width: 44,
      child: IconButton(
        icon: Icon(icon),
        onPressed: enabled ? onPressed : null,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      height: 36,
      width: 24,
      alignment: Alignment.center,
      child: const Text('...', style: TextStyle(fontSize: 16)),
    );
  }
}
