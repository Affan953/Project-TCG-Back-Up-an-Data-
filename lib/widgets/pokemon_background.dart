import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PokemonBackground extends StatelessWidget {
  final Widget child;

  const PokemonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0a1628), // Navy Dark
                Color(0xFF1a2847), // Royal Blue Dark
                Color(0xFF2d1b69), // Violet Purple
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        
        // Particles Layer
        const _ParticleLayer(),
        
        // Content
        SafeArea(child: child),
      ],
    );
  }
}

class _ParticleLayer extends StatelessWidget {
  const _ParticleLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Particle 1: Top 80, Left 80, 8x8, blue-400
        _buildParticle(top: 80, left: 80, size: 8, color: const Color(0xFF60a5fa), delay: 0.ms),
        
        // Particle 2: Top 160, Right 128, 4x4, yellow-400
        _buildParticle(top: 160, right: 128, size: 4, color: const Color(0xFFfbbf24), delay: 500.ms),
        
        // Particle 3: Bottom 128, Left 160, 6x6, purple-400
        _buildParticle(bottom: 128, left: 160, size: 6, color: const Color(0xFFc084fc), delay: 1000.ms),
        
        // Particle 4: Top 240, Right 80, 4x4, blue-300
        _buildParticle(top: 240, right: 80, size: 4, color: const Color(0xFF93c5fd), delay: 1500.ms),
        
        // Particle 5: Bottom 240, Right 240, 8x8, yellow-300
        _buildParticle(bottom: 240, right: 240, size: 8, color: const Color(0xFFfde047), delay: 2000.ms),
        
        // Particle 6: Top 50%, Left 40, 4x4, purple-300
        _buildParticle(top: MediaQuery.of(context).size.height * 0.5, left: 40, size: 4, color: const Color(0xFFd8b4fe), delay: 700.ms),
      ],
    );
  }

  Widget _buildParticle({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
    required Duration delay,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.35),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      )
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.4, 1.4),
            duration: 3000.ms,
            curve: Curves.easeInOut,
            delay: delay,
          )
          .move(
            begin: const Offset(-5, -5),
            end: const Offset(5, 5),
            duration: 4000.ms,
            curve: Curves.easeInOut,
            delay: delay,
          )
          .fadeOut(
            begin: 0.4,
            duration: 2500.ms,
            curve: Curves.easeInOut,
          ),
    );
  }
}
