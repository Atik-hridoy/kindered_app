import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavCard extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavCard({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            iconPath: 'assets/svg/explore.svg',
            index: 0,
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            iconPath: 'assets/svg/ai.svg',
            index: 1,
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            iconPath: 'assets/svg/Chat.svg',
            index: 2,
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            iconPath: 'assets/svg/menu Frame.svg',
            index: 3,
            isActive: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFD4A373).withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
          color: isActive ? const Color(0xFFD4A373) : Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}