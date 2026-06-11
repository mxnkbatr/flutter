import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
  });

  final String text;
  final int maxLines;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  bool _overflows = false;

  @override
  void didUpdateWidget(covariant ExpandableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _expanded = false;
      _overflows = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) {
      return Text('Танилцуулга байхгүй байна.', style: AppText.body);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final span = TextSpan(text: widget.text, style: AppText.body);
            final tp = TextPainter(
              text: span,
              maxLines: widget.maxLines,
              textDirection: Directionality.of(context),
            )..layout(maxWidth: constraints.maxWidth);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && tp.didExceedMaxLines != _overflows) {
                setState(() => _overflows = tp.didExceedMaxLines);
              }
            });

            return AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                widget.text,
                style: AppText.body,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(widget.text, style: AppText.body),
            );
          },
        ),
        if (_overflows || _expanded)
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _expanded = !_expanded);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _expanded ? 'Хураах' : 'Дэлгэрэнгүй',
              style: AppText.bodySmall.copyWith(color: AppColors.goldPrime),
            ),
          ),
      ],
    );
  }
}
