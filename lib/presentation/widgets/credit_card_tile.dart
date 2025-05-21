import 'package:card_nudge/presentation/widgets/payment_log_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/models/payment_model.dart';
import '../providers/bank_provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/payment_provider.dart';
import '../screens/add_card_screen.dart';
import '../screens/card_details_screen.dart';

class CreditCard extends ConsumerStatefulWidget {
  final CreditCardModel card;
  const CreditCard({super.key, required this.card});

  @override
  ConsumerState<CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends ConsumerState<CreditCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  double _swipeOffset = 0;
  SwipeAction? _currentAction;
  bool _showActionLabel = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return '₹${NumberFormat('#,##0.00').format(amount)}';
  }

  bool _isDueToday(List<PaymentModel> payments) {
    if (payments.isEmpty) return false;
    final dueDate = widget.card.dueDate;
    return dueDate.difference(DateTime.now()).inDays == 0 &&
        payments.last.dueAmount > 0;
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _handleSwipeAction(SwipeAction action) {
    _triggerHapticFeedback();

    switch (action) {
      case SwipeAction.delete:
        _deleteCard();
        break;
      case SwipeAction.archive:
        _archiveCard();
        break;
      case SwipeAction.favorite:
        _toggleFavorite();
        break;
      case SwipeAction.edit:
        _editCard();
        break;
    }
  }

  void _showPaymentBottomSheet() {
    final upcommingPayment = ref
        .watch(paymentProvider.notifier)
        .getUpcomingPayment(widget.card.id);
    if (upcommingPayment != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: LogPaymentBottomSheet(payment: upcommingPayment),
          );
        },
      );
    }
  }

  void _showCardDetails(List<PaymentModel> payments) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CardDetailsScreen(card: widget.card, payments: payments),
      ),
    );
  }

  Future<void> _deleteCard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Card'),
            content: const Text('Are you sure you want to delete this card?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      ref
          .read(creditCardListProvider.notifier)
          .deleteByKey(widget.card.key as int);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.card.name} deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed:
                () => ref
                    .read(creditCardListProvider.notifier)
                    .restoreByKey(widget.card.key as int, widget.card),
          ),
        ),
      );
    }
  }

  void _archiveCard() {
    // ref
    //     .read(creditCardListProvider.notifier)
    //     .updateByKey(widget.card.key, widget.card.copyWith(isArchived: true));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${widget.card.name} archived')));
  }

  void _toggleFavorite() {
    // ref
    //     .read(creditCardListProvider.notifier)
    //     .updateByKey(
    //       widget.card.key,
    //       widget.card.copyWith(isFavorite: !widget.card.isFavorite),
    //     );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.card.name} ${widget.card.isFavorite ? 'removed from' : 'added to'} favorites',
        ),
      ),
    );
  }

  void _editCard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCardScreen(card: widget.card)),
    );
  }

  SwipeAction? _getActionFromOffset(double offset) {
    if (offset < -100) return SwipeAction.delete; // Left swipe always delete
    if (offset > 100) {
      // Right swipe actions based on card state
      if (true) return SwipeAction.edit;
      if (widget.card.isFavorite) return SwipeAction.archive;
      return SwipeAction.favorite;
    }
    return null;
  }

  Color _getActionColor(SwipeAction action) {
    switch (action) {
      case SwipeAction.delete:
        return Colors.red;
      case SwipeAction.archive:
        return Colors.orange;
      case SwipeAction.favorite:
        return Colors.yellow[700]!;
      case SwipeAction.edit:
        return Colors.blue;
    }
  }

  IconData _getActionIcon(SwipeAction action) {
    switch (action) {
      case SwipeAction.delete:
        return Icons.delete;
      case SwipeAction.archive:
        return Icons.archive;
      case SwipeAction.favorite:
        return Icons.favorite;
      case SwipeAction.edit:
        return Icons.edit;
    }
  }

  String _getActionLabel(SwipeAction action) {
    switch (action) {
      case SwipeAction.delete:
        return 'Delete';
      case SwipeAction.archive:
        return 'Archive';
      case SwipeAction.favorite:
        return widget.card.isFavorite ? 'Unfavorite' : 'Favorite';
      case SwipeAction.edit:
        return 'Edit';
    }
  }

  @override
  Widget build(BuildContext context) {
    var payments =
        ref
            .watch(paymentProvider.notifier)
            .getPaymentsForCard(widget.card.id)
            .toList();

    final bank = ref.watch(bankProvider.notifier).getById(widget.card.bankId);
    final hasDue = payments.isNotEmpty && payments.last.dueAmount > 0;
    final isDueToday = _isDueToday(payments);

    return GestureDetector(
      onHorizontalDragStart: (_) {
        setState(() {
          _showActionLabel = false;
          _currentAction = null;
        });
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _swipeOffset += details.primaryDelta!;
          final newAction = _getActionFromOffset(_swipeOffset);
          if (newAction != _currentAction) {
            _currentAction = newAction;
            if (newAction != null) _triggerHapticFeedback();
          }
        });
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          if (_currentAction != null) {
            _showActionLabel = true;
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() => _showActionLabel = false);
                _handleSwipeAction(
                  _currentAction ?? SwipeAction.favorite,
                ); // TODO: Fix it
              }
            });
          }
          _swipeOffset = 0;
          _currentAction = null;
        });
      },
      child: Stack(
        children: [
          // Background action indicator
          if (_currentAction != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: _getActionColor(_currentAction!).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment:
                    _swipeOffset < 0
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    _getActionIcon(_currentAction!),
                    color: _getActionColor(_currentAction!),
                    size: 30,
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_swipeOffset.clamp(-50, 50), 0),
            child: AnimatedOpacity(
              opacity: _currentAction != null ? 0.8 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        onTap: () => _showCardDetails(payments),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Card details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.card.name} • ${bank.name}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text('**** ${widget.card.last4Digits}'),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Limit: ${_formatCurrency(widget.card.creditLimit)}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Current Due: ${hasDue ? _formatCurrency(payments.last.dueAmount) : "--"}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDueToday
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.error
                                                : null,
                                      ),
                                    ),
                                    if (isDueToday)
                                      ScaleTransition(
                                        scale: Tween(
                                          begin: 0.9,
                                          end: 1.1,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: _pulseController,
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                        child: Text(
                                          'Due Today!',
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Bank icon
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12.0,
                                  top: 4.0,
                                ),
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    return bank.logoPath != null
                                        ? SvgPicture.asset(
                                          bank.logoPath as String,
                                          width: 35,
                                          height: 35,
                                        )
                                        : const Icon(
                                          Icons.account_balance,
                                          size: 35,
                                        );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      TextButton(
                        onPressed: hasDue ? _showPaymentBottomSheet : null,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                        ),
                        child: const Text('LOG PAYMENT'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Action label overlay
          if (_showActionLabel && _currentAction != null)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getActionColor(_currentAction!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getActionLabel(_currentAction!),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum SwipeAction { delete, archive, favorite, edit }
