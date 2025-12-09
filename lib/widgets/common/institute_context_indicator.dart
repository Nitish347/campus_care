import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/services/institute_context_service.dart';
import 'package:campus_care/core/routes/app_routes.dart';

class InstituteContextIndicator extends StatelessWidget {
  const InstituteContextIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final contextService = Get.find<InstituteContextService>();
      final theme = Theme.of(context);

      return Obx(() {
        // Don't show if not in institute context
        if (!contextService.isInInstituteContext) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    contextService.currentInstituteName ?? 'Institute',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () async {
                      final shouldReturn = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Return to Super Admin'),
                          content: const Text(
                            'Do you want to return to the Super Admin dashboard?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Return'),
                            ),
                          ],
                        ),
                      );

                      if (shouldReturn == true) {
                        await contextService.clearInstituteContext();
                        Get.offAllNamed(AppRoutes.superAdminDashboard);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    } catch (e) {
      // Service not initialized yet, return empty widget
      return const SizedBox.shrink();
    }
  }
}
