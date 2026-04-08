import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.maxWidth = 448, // max-w-md
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 640;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 16,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Stack(
              children: [
                // Background and Border
                Container(
                  padding: EdgeInsets.only(
                    top: isDesktop ? 120 : 100,
                    bottom: isDesktop ? 48 : 36,
                    left: isDesktop ? 44 : 34,
                    right: isDesktop ? 44 : 34,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1.2,
                    ),
                  ),
                  child: child,
                ),
                
                // Top Shine Highlight
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  child: IgnorePointer(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Diagonal Sheen Overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.06),
                            Colors.transparent,
                            Colors.white.withOpacity(0.03),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
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
