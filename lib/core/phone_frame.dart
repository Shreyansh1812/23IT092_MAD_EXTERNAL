import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wraps [child] in a phone-shaped frame when running on web.
/// On native mobile, renders the child directly with no wrapper.
class PhoneFrame extends StatelessWidget {
  final Widget child;
  final ThemeMode themeMode;

  const PhoneFrame({super.key, required this.child, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    // Only show phone frame on web builds
    if (!kIsWeb) return child;

    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    const double phoneWidth = 393;
    const double phoneHeight = 852;
    const double cornerRadius = 52.0;
    const Color bezColor = Color(0xFF1A1A1A);

    return Container(
      color: isDark ? const Color(0xFF040E1C) : const Color(0xFFBAE6FD),
      child: Center(
        child: SizedBox(
          width: phoneWidth + 16,
          height: phoneHeight + 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // --- Outer bezel (phone body) ---
              Container(
                width: phoneWidth + 14,
                height: phoneHeight + 14,
                decoration: BoxDecoration(
                  color: bezColor,
                  borderRadius: BorderRadius.circular(cornerRadius + 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.55),
                      blurRadius: 60,
                      spreadRadius: 4,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: isDark
                          ? const Color(0xFF8B83FF).withOpacity(0.2)
                          : const Color(0xFF6C63FF).withOpacity(0.25),
                      blurRadius: 40,
                      spreadRadius: -4,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),

              // --- Screen area ---
              ClipRRect(
                borderRadius: BorderRadius.circular(cornerRadius),
                child: SizedBox(
                  width: phoneWidth,
                  height: phoneHeight,
                  child: Stack(
                    children: [
                      // The actual app
                      child,

                      // --- Status bar overlay (top) ---
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0D0D1A).withOpacity(0.95)
                                : const Color(0xFFF4F3FF).withOpacity(0.95),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '9:41',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A2E),
                                  ),
                                ),
                                // Dynamic island / notch
                                Container(
                                  width: 126,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.signal_cellular_alt,
                                        size: 16,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A2E)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.wifi,
                                        size: 16,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A2E)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.battery_full,
                                        size: 16,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A2E)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // --- Home indicator bar (bottom) ---
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 34,
                          color: isDark
                              ? const Color(0xFF071526).withOpacity(0.95)
                              : const Color(0xFFF0F9FF).withOpacity(0.95),
                          alignment: Alignment.center,
                          child: Container(
                            width: 134,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Side buttons (visual only) ---
              // Volume up
              Positioned(
                left: 0,
                top: phoneHeight * 0.22,
                child: Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Volume down
              Positioned(
                left: 0,
                top: phoneHeight * 0.31,
                child: Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Power button
              Positioned(
                right: 0,
                top: phoneHeight * 0.26,
                child: Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
