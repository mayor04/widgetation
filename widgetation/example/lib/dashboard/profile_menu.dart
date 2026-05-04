import 'package:flutter/material.dart';

import '../design/tokens.dart';

class ProfileAvatarButton extends StatefulWidget {
  const ProfileAvatarButton({super.key});

  @override
  State<ProfileAvatarButton> createState() => _ProfileAvatarButtonState();
}

class _ProfileAvatarButtonState extends State<ProfileAvatarButton> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  void _toggle() {
    if (_entry != null) {
      _close();
      return;
    }
    final entry = OverlayEntry(
      builder: (_) => _ProfileMenuOverlay(
        link: _link,
        onDismiss: _close,
      ),
    );
    _entry = entry;
    Overlay.of(context).insert(entry);
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        child: const ProfileAvatar(initials: 'M'),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String initials;
  const ProfileAvatar({super.key, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppType.caption.copyWith(
          color: AppColors.onDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileMenuOverlay extends StatelessWidget {
  final LayerLink link;
  final VoidCallback onDismiss;
  const _ProfileMenuOverlay({required this.link, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 8),
          child: const ProfileMenuCard(),
        ),
      ],
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.canvas,
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _ProfileHeader(),
            Divider(height: 1, color: AppColors.hairlineSoft),
            _ProfileMenuItem(icon: Icons.person_outline, label: 'View profile'),
            _ProfileMenuItem(icon: Icons.tune, label: 'Preferences'),
            _ProfileMenuItem(icon: Icons.workspace_premium_outlined, label: 'Billing'),
            Divider(height: 1, color: AppColors.hairlineSoft),
            _ProfileMenuItem(icon: Icons.logout, label: 'Sign out'),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const ProfileAvatar(initials: 'M'),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mayor', style: AppType.titleMd),
                Text(
                  'mayor@anthropic.com',
                  style: AppType.caption.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ProfileMenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.ink),
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppType.bodySm),
          ],
        ),
      ),
    );
  }
}
