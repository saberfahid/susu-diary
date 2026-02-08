import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AIWritingToolbar extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onEnhance;
  final VoidCallback onExpand;
  final VoidCallback onFixGrammar;

  const AIWritingToolbar({
    super.key,
    required this.isProcessing,
    required this.onEnhance,
    required this.onExpand,
    required this.onFixGrammar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolButton(
                    context: context,
                    icon: Icons.auto_awesome,
                    label: 'Enhance',
                    color: AppTheme.primaryColor,
                    onPressed: isProcessing ? null : onEnhance,
                  ),
                  const SizedBox(width: 8),
                  _buildToolButton(
                    context: context,
                    icon: Icons.expand,
                    label: 'Expand',
                    color: AppTheme.secondaryColor,
                    onPressed: isProcessing ? null : onExpand,
                  ),
                  const SizedBox(width: 8),
                  _buildToolButton(
                    context: context,
                    icon: Icons.spellcheck,
                    label: 'Grammar',
                    color: AppTheme.accentColor,
                    onPressed: isProcessing ? null : onFixGrammar,
                  ),
                ],
              ),
            ),
          ),
          if (isProcessing)
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
