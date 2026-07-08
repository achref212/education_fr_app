import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class SelectionItem {
  const SelectionItem({
    required this.id,
    required this.label,
    this.subtitle,
  });

  final String id;
  final String label;
  final String? subtitle;
}

Future<SelectionItem?> showSelectionBottomSheet({
  required BuildContext context,
  required String title,
  required List<SelectionItem> items,
  String? searchHint,
  SelectionItem? extraItem,
}) {
  return showModalBottomSheet<SelectionItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _SelectionBottomSheet(
      title: title,
      items: items,
      searchHint: searchHint,
      extraItem: extraItem,
    ),
  );
}

class _SelectionBottomSheet extends StatefulWidget {
  const _SelectionBottomSheet({
    required this.title,
    required this.items,
    this.searchHint,
    this.extraItem,
  });

  final String title;
  final List<SelectionItem> items;
  final String? searchHint;
  final SelectionItem? extraItem;

  @override
  State<_SelectionBottomSheet> createState() => _SelectionBottomSheetState();
}

class _SelectionBottomSheetState extends State<_SelectionBottomSheet> {
  String _query = '';

  List<SelectionItem> get _filteredItems {
    if (_query.isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((item) {
      final labelMatch = item.label.toLowerCase().contains(q);
      final subtitleMatch = item.subtitle?.toLowerCase().contains(q) ?? false;
      return labelMatch || subtitleMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.searchHint != null) ...[
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ..._filteredItems.map(
                      (item) => _SelectionRow(
                        label: item.label,
                        subtitle: item.subtitle,
                        onTap: () => Navigator.pop(context, item),
                      ),
                    ),
                    if (widget.extraItem != null) ...[
                      const SizedBox(height: 8),
                      _SelectionRow(
                        label: widget.extraItem!.label,
                        subtitle: widget.extraItem!.subtitle,
                        isHighlighted: true,
                        onTap: () => Navigator.pop(context, widget.extraItem),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.label,
    required this.onTap,
    this.subtitle,
    this.isHighlighted = false,
  });

  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary;
    final subColor =
        isDark ? AppColors.darkBodySecondary : AppColors.lightBodySecondary;

    return Material(
      color: isHighlighted
          ? (isDark ? AppColors.darkSurfacePrimary : AppColors.lightSurfacePrimary)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isHighlighted ? AppColors.primary : textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(color: subColor),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isHighlighted ? AppColors.primary : subColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
