import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool animated;

  const AppLogo({
    super.key,
    this.size = 100,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    return animated
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: _buildLogo(),
          )
        : _buildLogo();
  }

  Widget _buildLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to the original custom logo if image fails to load
            return _buildFallbackLogo();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.yellow.shade300,
            Colors.orange.shade400,
            Colors.red.shade400,
          ],
          stops: const [0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sun rays
          ...List.generate(16, (index) {
            final angle = (index * 22.5) * (3.14159 / 180);
            return Transform.rotate(
              angle: angle,
              child: Container(
                width: size * 0.15,
                height: size * 0.8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.yellow.shade300,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          }),
          // Central circle with Kurdish Taboo elements
          Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Speech bubble
                  Icon(
                    Icons.chat_bubble,
                    color: Colors.blue.shade600,
                    size: size * 0.15,
                  ),
                  SizedBox(width: size * 0.02),
                  // Sound waves
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size * 0.08,
                        height: size * 0.08,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(size * 0.02),
                        ),
                      ),
                      SizedBox(height: size * 0.01),
                      Container(
                        width: size * 0.12,
                        height: size * 0.12,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade500,
                          borderRadius: BorderRadius.circular(size * 0.03),
                        ),
                      ),
                      SizedBox(height: size * 0.01),
                      Container(
                        width: size * 0.16,
                        height: size * 0.16,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius: BorderRadius.circular(size * 0.04),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
