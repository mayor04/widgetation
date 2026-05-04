import 'package:flutter/material.dart';

import '../design/components.dart';
import '../design/tokens.dart';

class InviteTeammateDialog extends StatelessWidget {
  const InviteTeammateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _InviteHeader(),
              const SizedBox(height: AppSpacing.lg),
              const _InviteEmailField(),
              const SizedBox(height: AppSpacing.md),
              const _InviteRoleSelector(),
              const SizedBox(height: AppSpacing.xl),
              _InviteActions(
                onCancel: () => Navigator.of(context).pop(),
                onSend: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteHeader extends StatelessWidget {
  const _InviteHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionEyebrow(label: 'Workspace'),
        const SizedBox(height: AppSpacing.sm),
        Text('Invite a teammate', style: AppType.displaySm),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'They will get access to all conversations and connectors.',
          style: AppType.bodyMd,
        ),
      ],
    );
  }
}

class _InviteEmailField extends StatelessWidget {
  const _InviteEmailField();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email', style: AppType.captionUppercase),
        const SizedBox(height: AppSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: const TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'name@company.com',
            ),
          ),
        ),
      ],
    );
  }
}

class _InviteRoleSelector extends StatelessWidget {
  const _InviteRoleSelector();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _RoleChip(label: 'Viewer', selected: false),
        SizedBox(width: AppSpacing.xs),
        _RoleChip(label: 'Editor', selected: true),
        SizedBox(width: AppSpacing.xs),
        _RoleChip(label: 'Admin', selected: false),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _RoleChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppType.caption.copyWith(
          color: selected ? AppColors.onPrimary : AppColors.ink,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InviteActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSend;
  const _InviteActions({required this.onCancel, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ButtonSecondary(label: 'Cancel', onPressed: onCancel),
        const SizedBox(width: AppSpacing.sm),
        ButtonPrimary(label: 'Send invite', onPressed: onSend),
      ],
    );
  }
}
