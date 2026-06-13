import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/ad_service.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/food_item.dart';
import '../providers/swipe_controller.dart';
import '../providers/providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/food_card.dart';

/// The core CookSwipe experience: one dish at a time.
/// Swipe right = "I want this dish" → saved to Today's Menu + Favorites.
/// Swipe left  = "show another suggestion".
class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key, required this.category});

  final MealCategory category;

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  bool _showSuccess = false;
  bool _deckExhausted = false;
  FoodItem? _selectedFood;
  int _lastLoggedIndex = -1;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  SwipeController get _controller =>
      ref.read(swipeControllerProvider(widget.category).notifier);

  void _logCardShown(List<FoodItem> queue, int index) {
    if (index == _lastLoggedIndex || index >= queue.length) return;
    _lastLoggedIndex = index;
    _controller.onCardShown(queue[index]);
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
    List<FoodItem> queue,
  ) {
    final food = queue[previousIndex];
    if (direction == CardSwiperDirection.right) {
      _onSelect(food);
    } else {
      _controller.skip(food);
    }
    if (currentIndex != null) _logCardShown(queue, currentIndex);
    return true;
  }

  Future<void> _onSelect(FoodItem food) async {
    // Capture before any navigation: ref must not be used after dispose.
    final AdService adService = ref.read(adServiceProvider);

    await _controller.select(food);
    if (!mounted) return;
    setState(() {
      _selectedFood = food;
      _showSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 1300));
    if (mounted) Navigator.of(context).pop();

    // Monetization rule: a single interstitial per day, only after the
    // first successful selection. The service enforces the cap.
    await adService.maybeShowPostSelectionAd();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(swipeControllerProvider(widget.category));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.emoji}  ${widget.category.label}'),
      ),
      body: Stack(
        children: [
          _buildBody(state),
          if (_showSuccess) _SuccessOverlay(food: _selectedFood!),
        ],
      ),
    );
  }

  Widget _buildBody(SwipeState state) {
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Something went wrong',
        message: state.error!,
        actionLabel: 'Try again',
        onAction: () => _controller.loadQueue(),
      );
    }
    if (state.queue.isEmpty || _deckExhausted) {
      return EmptyState(
        icon: Icons.ramen_dining_rounded,
        title: "You've seen everything!",
        message:
            'No more matching suggestions for now. Reshuffle to see dishes again.',
        actionLabel: 'Reshuffle suggestions',
        onAction: () {
          setState(() {
            _deckExhausted = false;
            _lastLoggedIndex = -1;
          });
          _controller.loadQueue(relaxVariety: true);
        },
      );
    }

    final queue = state.queue;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _logCardShown(queue, 0));

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: CardSwiper(
              controller: _swiperController,
              cardsCount: queue.length,
              numberOfCardsDisplayed: min(3, queue.length),
              isLoop: false,
              backCardOffset: const Offset(0, 36),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              allowedSwipeDirection:
                  const AllowedSwipeDirection.only(left: true, right: true),
              onSwipe: (prev, current, direction) =>
                  _onSwipe(prev, current, direction, queue),
              onEnd: () => setState(() => _deckExhausted = true),
              cardBuilder: (context, index, hThreshold, vThreshold) =>
                  FoodCard(food: queue[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.close_rounded,
                  color: Colors.grey.shade700,
                  background: Colors.white,
                  label: 'Another one',
                  onTap: () =>
                      _swiperController.swipe(CardSwiperDirection.left),
                ),
                _ActionButton(
                  icon: Icons.check_rounded,
                  color: Colors.white,
                  background: AppTheme.saffron,
                  label: "I'll cook this!",
                  onTap: () =>
                      _swiperController.swipe(CardSwiperDirection.right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: background,
          shape: const CircleBorder(),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Icon(icon, size: 32, color: color),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _SuccessOverlay extends StatelessWidget {
  const _SuccessOverlay({required this.food});

  final FoodItem food;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 450),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.vegGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Added to Today\'s Menu!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.deepCharcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    food.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.saffron,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
