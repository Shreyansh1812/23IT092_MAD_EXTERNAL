import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'trip_provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../core/theme_provider.dart';

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradient = isDark ? AppTheme.darkPrimaryGradient : AppTheme.primaryGradient;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'My Trips ✈️',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(decoration: BoxDecoration(gradient: gradient)),
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 30,
                    right: 30,
                    child: Icon(Icons.flight_takeoff_rounded,
                        size: 70, color: Colors.white24),
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                  tooltip: 'Toggle theme',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  onPressed: () => context.push('/search'),
                  tooltip: 'Search & Filter',
                ),
              ),
            ],
          ),

          if (trips.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                          gradient: gradient, shape: BoxShape.circle),
                      child: const Icon(Icons.card_travel_rounded,
                          size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Text('No trips planned yet',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to create your first adventure!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final trip = trips[index];
                    final duration =
                        trip.endDate.difference(trip.startDate).inDays;
                    final gradients = [
                      AppTheme.primaryGradient,
                      AppTheme.sunsetGradient,
                      AppTheme.oceanGradient,
                      AppTheme.darkPrimaryGradient,
                    ];
                    final cardGradient = gradients[index % gradients.length];
                    return _TripCard(
                        trip: trip, duration: duration, gradient: cardGradient);
                  },
                  childCount: trips.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-trip'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Trip'),
        elevation: 6,
      ),
    );
  }
}

class _TripCard extends StatefulWidget {
  final dynamic trip;
  final int duration;
  final LinearGradient gradient;
  const _TripCard(
      {required this.trip, required this.duration, required this.gradient});
  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 140));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          context.push('/dashboard/${widget.trip.id}');
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first
                    .withOpacity(isDark ? 0.25 : 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Accent bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                      height: 4,
                      decoration: BoxDecoration(gradient: widget.gradient)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F2044) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color:
                            widget.gradient.colors.first.withOpacity(0.18)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.trip.name,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: widget.gradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${widget.duration}d',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (b) =>
                                widget.gradient.createShader(b),
                            child: const Icon(Icons.location_on_rounded,
                                size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.trip.destination,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.75)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (b) =>
                                widget.gradient.createShader(b),
                            child: const Icon(Icons.calendar_month_rounded,
                                size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${DateFormat('MMM d').format(widget.trip.startDate)} – ${DateFormat('MMM d, y').format(widget.trip.endDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(
                          height: 1,
                          color: theme.colorScheme.outlineVariant
                              .withOpacity(0.35)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: (widget.trip.participants.length > 3
                                        ? 3
                                        : widget.trip.participants.length) *
                                    22.0 +
                                10,
                            height: 32,
                            child: Stack(
                              children: List.generate(
                                widget.trip.participants.length > 3
                                    ? 3
                                    : widget.trip.participants.length,
                                (i) => Positioned(
                                  left: i * 18.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: isDark
                                              ? const Color(0xFF0F2044)
                                              : Colors.white,
                                          width: 2),
                                      gradient: widget.gradient,
                                    ),
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.transparent,
                                      child: Text(
                                        widget.trip.participants[i][0]
                                            .toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (widget.trip.participants.length > 3)
                            Text(
                              '+${widget.trip.participants.length - 3}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                  fontWeight: FontWeight.w600),
                            ),
                          const Spacer(),
                          Text(
                            '${widget.trip.participants.length} travellers',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color:
                                    theme.colorScheme.onSurface.withOpacity(0.5)),
                          ),
                          const SizedBox(width: 8),
                          ShaderMask(
                            shaderCallback: (b) =>
                                widget.gradient.createShader(b),
                            child: const Icon(Icons.arrow_forward_ios_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
