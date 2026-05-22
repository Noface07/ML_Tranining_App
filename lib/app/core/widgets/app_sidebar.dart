import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../../data/local/preference/app_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSidebar extends StatelessWidget {
  final String selectedRoute;
  final ValueChanged<String> onNavigate;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const AppSidebar({
    super.key,
    required this.selectedRoute,
    required this.onNavigate,
    this.isCollapsed = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? AppDimensions.sidebarCollapsedWidth : AppDimensions.sidebarWidth,
      curve: Curves.easeInOut,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.sidebarBorder),
        ),
      ),
      child: Column(
        children: [
          // Header / Brand
          Padding(
            padding: EdgeInsets.fromLTRB(
              isCollapsed ? 4 : 16, // Reduced horizontal padding in collapsed mode
              24,
              isCollapsed ? 4 : 16,
              8,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: isCollapsed ? AppDimensions.sidebarCollapsedWidth - 8 : AppDimensions.sidebarWidth - 32,
                child: Row(
                  mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    if (!isCollapsed) ...[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.white  ,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          'assets/images/group_15123.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.appName,
                              style: AppTextStyles.sidebarBrand,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              AppStrings.appSubtitleML,
                              style: AppTextStyles.sidebarSub,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Wrap IconButton in a fixed size container or reduce its padding to prevent overflow
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: onToggle,
                        icon: Icon(
                          isCollapsed ? Icons.menu : Icons.menu_open,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Nav items
          _NavItem(
            icon: Icons.grid_view_rounded,
            label: AppStrings.dashboard,
            isActive: selectedRoute == '/',
            onTap: () => onNavigate('/'),
            isCollapsed: isCollapsed,
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: AppStrings.settings,
            isActive: selectedRoute == '/settings',
            onTap: () {},
            isCollapsed: isCollapsed,
          ),

          const Spacer(),

          // Divider
          if (!isCollapsed) const Divider(indent: 16, endIndent: 16),

          const SizedBox(height: 8),

          // Bottom items
          _NavItem(
            icon: Icons.help_outline_rounded,
            label: AppStrings.helpCenter,
            isActive: false,
            onTap: () {},
            isCollapsed: isCollapsed,
          ),
          _NavItem(
            icon: Icons.logout_rounded,
            label: AppStrings.signOut,
            isActive: false,
            onTap: () async {
              await AppPreferences.remove('auth_token');
              if (context.mounted) {
                onNavigate('/signin');
              }
            },
            isCollapsed: isCollapsed,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCollapsed;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isCollapsed = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.isCollapsed ? 8 : 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHover: (hovering) => setState(() => _isHovered = hovering),
          hoverColor: Colors.transparent, // We handle hover color in AnimatedContainer
          splashColor: AppColors.primaryLight.withOpacity(0.3),
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppColors.activeNavBg
                  : _isHovered
                      ? AppColors.scaffoldBg
                      : AppColors.scaffoldBg.withAlpha(0),
              borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: widget.isCollapsed ? AppDimensions.sidebarCollapsedWidth - 40 : AppDimensions.sidebarWidth - 48,
                child: Row(
                  mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Icon(
                      widget.icon,
                      size: 20,
                      color: widget.isActive
                          ? AppColors.activeNavText
                          : AppColors.inactiveNavText,
                    ),
                    if (!widget.isCollapsed) ...[
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          widget.label,
                          style: AppTextStyles.sidebarNav.copyWith(
                            color: widget.isActive
                                ? AppColors.activeNavText
                                : AppColors.inactiveNavText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
