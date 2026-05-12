import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../providers/language_provider.dart';

/// Shows Log out vs Stay; returns `true` only when the user confirms logout.
Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  final lang = LanguageProvider.to;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          lang.t('logoutConfirmTitle'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          lang.t('logoutConfirmMessage'),
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(lang.t('logoutConfirmStay')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
            ),
            child: Text(lang.t('accountLogOut')),
          ),
        ],
      );
    },
  );
  return result == true;
}
