import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/cards/card_list_provider.dart';
import '../../../domain/card/card_entity.dart';
import '../../widgets_shared/digital_card_widget.dart';
import 'hollow_card_empty_state.dart';

/// The home screen's signature overlapping card stack:
/// - Tap the front card to open its detail.
/// - Dragging vertically on the front card cycles through the stack live,
///   distance-driven rather than gated on release: a short flick cycles one
///   card, a long sustained drag fans rapidly through many with a haptic
///   tick per card, like riffling a deck. Browsing never changes the saved
///   order.
/// - A long-press-and-drag on any visible card reorders the stack and
///   persists the new order.
class CardStackView extends ConsumerStatefulWidget {
  const CardStackView({
    super.key,
    required this.cards,
    required this.onOpenCard,
    this.isFiltered = false,
  });

  final List<CardEntity> cards;
  final void Function(CardEntity card) onOpenCard;

  /// True when [cards] is empty because a search/filter matched nothing,
  /// as opposed to the vault genuinely having no cards yet.
  final bool isFiltered;

  @override
  ConsumerState<CardStackView> createState() => _CardStackViewState();
}

class _CardStackViewState extends ConsumerState<CardStackView>
    with SingleTickerProviderStateMixin {
  static const _maxVisible = 5;
  static const _depthOffset = 16.0;
  static const _depthScaleStep = 0.045;

  /// Pixels of cumulative vertical drag needed to cycle one card. Small
  /// enough that a sustained drag fans through several cards a second.
  static const _cyclePixelsPerCard = 45.0;

  int _browseRotation = 0;
  double _cycleAccumulator = 0;
  String? _draggingId;
  Offset _dragDelta = Offset.zero;
  List<String>? _previousCardIds;

  List<CardEntity> get _effectiveOrder {
    final cards = widget.cards;
    if (cards.isEmpty) return cards;
    final rotation = _browseRotation % cards.length;
    if (rotation == 0) return cards;
    return [...cards.sublist(rotation), ...cards.sublist(0, rotation)];
  }

  @override
  void didUpdateWidget(covariant CardStackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = widget.cards.map((c) => c.id).toList();
    if (_previousCardIds != null && _previousCardIds.toString() != ids.toString()) {
      _browseRotation = 0;
    }
    _previousCardIds = ids;
  }

  void _onBrowseDragStart() {
    _cycleAccumulator = 0;
  }

  void _onBrowseDragUpdate(DragUpdateDetails details) {
    if (widget.cards.length < 2) return;

    // Dragging up cycles forward (front card moves to the back); dragging
    // down cycles backward (brings the previous card back to front).
    _cycleAccumulator += -details.delta.dy;

    while (_cycleAccumulator >= _cyclePixelsPerCard) {
      _cycleAccumulator -= _cyclePixelsPerCard;
      _cycleStack(1);
    }
    while (_cycleAccumulator <= -_cyclePixelsPerCard) {
      _cycleAccumulator += _cyclePixelsPerCard;
      _cycleStack(-1);
    }
  }

  void _onBrowseDragEnd(DragEndDetails details) {
    _cycleAccumulator = 0;
  }

  void _cycleStack(int steps) {
    HapticFeedback.selectionClick();
    setState(() {
      _browseRotation =
          (_browseRotation + steps) % widget.cards.length;
    });
  }

  void _onTapFront(CardEntity card) {
    HapticFeedback.selectionClick();
    widget.onOpenCard(card);
  }

  void _beginDrag(String id) {
    HapticFeedback.mediumImpact();
    setState(() {
      _draggingId = id;
      _dragDelta = Offset.zero;
    });
  }

  void _updateDrag(Offset delta) {
    setState(() => _dragDelta = delta);
  }

  void _endDrag(List<CardEntity> order) {
    final draggingId = _draggingId;
    if (draggingId == null) return;

    final currentIndex = order.indexWhere((c) => c.id == draggingId);
    final indexDelta = (_dragDelta.dy / _depthOffset).round();
    final targetIndex = (currentIndex + indexDelta).clamp(0, order.length - 1);

    setState(() {
      _draggingId = null;
      _dragDelta = Offset.zero;
    });

    if (targetIndex != currentIndex) {
      HapticFeedback.mediumImpact();
      final reordered = [...order];
      final moved = reordered.removeAt(currentIndex);
      reordered.insert(targetIndex, moved);
      _browseRotation = 0;
      ref
          .read(cardListProvider.notifier)
          .reorder(reordered.map((c) => c.id).toList());
    } else {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _effectiveOrder;
    if (order.isEmpty) {
      if (widget.isFiltered) {
        return const HollowCardEmptyState(
          message: 'No cards match your search.',
        );
      }
      return Center(
        child: Text(
          'No cards yet.\nTap + to add your first card.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final visibleCount = order.length.clamp(0, _maxVisible);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * 0.86;
        final cardHeight = cardWidth / cardAspectRatio;
        final stackHeight =
            cardHeight + (_maxVisible - 1) * _depthOffset + 24;

        // Render back-to-front so later children draw on top; the dragged
        // card is always appended last so it stays above everything.
        final children = <Widget>[];
        for (var depth = visibleCount - 1; depth >= 0; depth--) {
          final card = order[depth];
          final isDragging = card.id == _draggingId;
          if (isDragging) continue;
          children.add(
            _StackCard(
              key: ValueKey(card.id),
              card: card,
              depth: depth,
              width: cardWidth,
              depthOffset: _depthOffset,
              depthScaleStep: _depthScaleStep,
              isFront: depth == 0,
              onTap: depth == 0 ? () => _onTapFront(card) : null,
              onBrowseDragStart: depth == 0 ? _onBrowseDragStart : null,
              onBrowseDragUpdate: depth == 0 ? _onBrowseDragUpdate : null,
              onBrowseDragEnd: depth == 0 ? _onBrowseDragEnd : null,
              onLongPressStart: () => _beginDrag(card.id),
              onLongPressMove: _updateDrag,
              onLongPressEnd: () => _endDrag(order),
            ),
          );
        }

        if (_draggingId != null) {
          final draggingCard = order.firstWhere((c) => c.id == _draggingId);
          final depth = order.indexOf(draggingCard);
          children.add(
            _StackCard(
              key: ValueKey('${draggingCard.id}-dragging'),
              card: draggingCard,
              depth: depth,
              width: cardWidth,
              depthOffset: _depthOffset,
              depthScaleStep: _depthScaleStep,
              isFront: true,
              dragOffset: _dragDelta,
              onLongPressStart: () {},
              onLongPressMove: _updateDrag,
              onLongPressEnd: () => _endDrag(order),
            ),
          );
        }

        return SizedBox(
          height: stackHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: children,
          ),
        );
      },
    );
  }
}

class _StackCard extends StatelessWidget {
  const _StackCard({
    super.key,
    required this.card,
    required this.depth,
    required this.width,
    required this.depthOffset,
    required this.depthScaleStep,
    required this.isFront,
    this.onTap,
    this.onBrowseDragStart,
    this.onBrowseDragUpdate,
    this.onBrowseDragEnd,
    this.dragOffset = Offset.zero,
    required this.onLongPressStart,
    required this.onLongPressMove,
    required this.onLongPressEnd,
  });

  final CardEntity card;
  final int depth;
  final double width;
  final double depthOffset;
  final double depthScaleStep;
  final bool isFront;
  final VoidCallback? onTap;
  final VoidCallback? onBrowseDragStart;
  final void Function(DragUpdateDetails details)? onBrowseDragUpdate;
  final void Function(DragEndDetails details)? onBrowseDragEnd;
  final Offset dragOffset;
  final VoidCallback onLongPressStart;
  final void Function(Offset delta) onLongPressMove;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final scale = 1 - depth * depthScaleStep;
    final top = depth * depthOffset + dragOffset.dy;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      top: top,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        scale: scale,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: 1 - depth * 0.08,
          child: GestureDetector(
            onTap: onTap,
            onVerticalDragStart: onBrowseDragStart != null
                ? (_) => onBrowseDragStart!()
                : null,
            onVerticalDragUpdate: onBrowseDragUpdate,
            onVerticalDragEnd: onBrowseDragEnd,
            onLongPressStart: (_) => onLongPressStart(),
            onLongPressMoveUpdate: (details) =>
                onLongPressMove(details.offsetFromOrigin),
            onLongPressEnd: (_) => onLongPressEnd(),
            child: SizedBox(
              width: width,
              child: Hero(
                tag: 'card-${card.id}',
                child: DigitalCardFront(card: card),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
