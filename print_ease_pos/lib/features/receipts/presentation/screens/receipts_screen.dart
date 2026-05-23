import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_dismissible_delete.dart';
import '../../../../shared/widgets/print_status_chip.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/receipt_provider.dart';
import '../../data/models/receipt.dart';
import '../../../pdf_export/presentation/widgets/download_pdf_button.dart';

enum _DateRange { all, today, week, month }

class ReceiptsScreen extends ConsumerStatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  ConsumerState<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends ConsumerState<ReceiptsScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  _DateRange _selectedDateRange = _DateRange.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(receiptProvider.notifier).loadReceipts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Receipts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.receiptCreate),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(state),
          Expanded(child: _buildList(context, state)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search receipt number...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(receiptProvider.notifier).setSearchQuery('');
                  },
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (value) {
          _searchDebounce?.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 300), () {
            ref.read(receiptProvider.notifier).setSearchQuery(value);
          });
        },
      ),
    );
  }

  Widget _buildFilterChips(ReceiptState state) {
    final statuses = <PrintStatus?>[null, PrintStatus.notPrinted, PrintStatus.printed, PrintStatus.failed];
    final labels = ['All', 'Not Printed', 'Printed', 'Failed'];
    final icons = [Icons.all_inclusive, Icons.print_disabled, Icons.print, Icons.error_outline];

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(statuses.length, (i) {
                final selected = state.filterStatus == statuses[i];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(labels[i]),
                    avatar: Icon(icons[i], size: 16),
                    selected: selected,
                    onSelected: (_) {
                      ref.read(receiptProvider.notifier).setFilterStatus(statuses[i]);
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _DateRange.values.map((range) {
                final selected = _selectedDateRange == range;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(_dateRangeLabel(range)),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedDateRange = range);
                      _applyDateFilter(range);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _dateRangeLabel(_DateRange range) {
    switch (range) {
      case _DateRange.all: return 'All Time';
      case _DateRange.today: return 'Today';
      case _DateRange.week: return 'This Week';
      case _DateRange.month: return 'This Month';
    }
  }

  void _applyDateFilter(_DateRange range) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (range) {
      case _DateRange.all:
        break;
      case _DateRange.today:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case _DateRange.week:
        final weekday = now.weekday;
        start = DateTime(now.year, now.month, now.day - weekday + 1);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case _DateRange.month:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
    }

    ref.read(receiptProvider.notifier).setDateFilter(start, end);
  }

  Widget _buildList(BuildContext context, ReceiptState state) {
    if (state.isLoading) {
      return const AppLoader();
    }
    if (state.error != null) {
      return AppErrorView(
        message: state.error!,
        onRetry: () => ref.read(receiptProvider.notifier).loadReceipts(),
      );
    }
    if (state.receipts.isEmpty) {
      return const AppEmptyView(message: 'No receipts found');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(receiptProvider.notifier).loadReceipts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: state.receipts.length,
        itemBuilder: (context, index) {
          final receipt = state.receipts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppDismissibleDelete(
              itemKey: ValueKey(receipt.id),
              confirmTitle: 'Delete Receipt',
              confirmMessage: 'Delete receipt #${receipt.receiptNumber}?',
              onDelete: () {
                ref.read(receiptProvider.notifier).deleteReceipt(receipt.id!);
              },
              child: AppCard(
                child: ListTile(
                  title: Text('#${receipt.receiptNumber}',
                      style: Theme.of(context).textTheme.titleSmall),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (receipt.customerName.isNotEmpty)
                        Text(receipt.customerName),
                      Text(
                        '${receipt.items.length} items',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Row(
                        children: [
                          PrintStatusChip(
                            status: receipt.printStatus,
                            label: receipt.printStatusLabel,
                          ),
                          DownloadPdfButton(
                            receiptId: receipt.id!,
                            compact: true,
                          ),
                          const Spacer(),
                          Flexible(
                            child: Text(
                              _formatDate(receipt.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${receipt.currency} ${receipt.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    ref.read(receiptProvider.notifier).selectReceipt(receipt);
                    context.push('/receipts/${receipt.id}');
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
