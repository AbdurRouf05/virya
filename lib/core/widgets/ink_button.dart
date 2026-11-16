import 'package:flutter/material.dart';
import 'package:virya/app/theme/field_notes.dart';

enum InkButtonStyle { primary, outline, ink, danger }

/// Square printed-block button. The hard shadow collapses on press.
class InkButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final InkButtonStyle style;
  final bool expand;
  final bool busy;
  final double height;

  const InkButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.style = InkButtonStyle.outline,
    this.expand = false,
    this.busy = false,
    this.height = 48,
  });

  @override
  State<InkButton> createState() => _InkButtonState();
}

class _InkButtonState extends State<InkButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ink = scheme.onSurface;
    final enabled = widget.onPressed != null && !widget.busy;
    final (Color bg, Color fg, Color border) = switch (widget.style) {
      InkButtonStyle.primary => (FN.signal, FN.onAccent, FN.ink),
      InkButtonStyle.ink => (ink, scheme.surface, ink),
      InkButtonStyle.danger => (Colors.transparent, FN.warn, FN.warn),
      InkButtonStyle.outline => (Colors.transparent, ink, ink),
    };
    if (FN.isClean) return _clean(enabled, scheme);
    final shadow =
        widget.style == InkButtonStyle.primary ||
        widget.style == InkButtonStyle.ink;
    final offset = _down || !enabled ? 0.0 : 3.0;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.busy)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: 18, color: fg),
        if (widget.busy || widget.icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            FN.caps(widget.label),
            overflow: TextOverflow.ellipsis,
            style: FN
                .label(size: 12.5, color: fg)
                .copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.6),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: Opacity(
          opacity: enabled || widget.busy ? 1 : 0.4,
          child: Padding(
            padding: EdgeInsets.only(
              right: shadow ? 3 : 0,
              bottom: shadow ? 3 : 0,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 70),
              height: widget.height,
              transform: Matrix4.translationValues(
                shadow ? 3 - offset : 0,
                shadow ? 3 - offset : 0,
                0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(color: border, width: 1.5),
                boxShadow: shadow && offset > 0
                    ? [BoxShadow(color: ink, offset: Offset(offset, offset))]
                    : null,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  /// Gaya Bersih: blok bersudut tanpa garis tebal dan tanpa bayangan;
  /// tekan = sedikit memudar.
  Widget _clean(bool enabled, ColorScheme scheme) {
    final (Color bg, Color fg, Color? border) = switch (widget.style) {
      InkButtonStyle.primary => (FN.signal, FN.onNight, null),
      InkButtonStyle.ink => (FN.ink, FN.paper, null),
      InkButtonStyle.danger => (FN.cardFill, FN.warn, FN.paperLine),
      InkButtonStyle.outline => (FN.cardFill, FN.ink, FN.paperLine),
    };
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 90),
          opacity: !enabled && !widget.busy ? 0.4 : (_down ? 0.75 : 1),
          child: Container(
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: FN.smallRadius,
              border: border == null ? null : Border.all(color: border),
            ),
            child: _cleanContent(fg),
          ),
        ),
      ),
    );
  }

  Widget _cleanContent(Color fg) => Row(
    mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (widget.busy)
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: fg),
        )
      else if (widget.icon != null)
        Icon(widget.icon, size: 18, color: fg),
      if (widget.busy || widget.icon != null) const SizedBox(width: 8),
      Flexible(
        child: Text(
          FN.caps(widget.label),
          overflow: TextOverflow.ellipsis,
          style: FN.heading(size: 14, color: fg),
        ),
      ),
    ],
  );
}

/// Small square icon button with ink border.
class InkIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  const InkIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final btn = InkWell(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: FN.isClean
            ? BoxDecoration(
                color: FN.cardFill,
                borderRadius: FN.smallRadius,
                border: Border.all(color: FN.paperLine),
              )
            : BoxDecoration(border: Border.all(color: fg, width: 1)),
        child: Icon(icon, size: size * 0.5, color: fg),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

/// Square on/off toggle (replaces the Material switch).
class InkToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const InkToggle({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final clean = FN.isClean;
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 48,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: clean
              ? BoxDecoration(
                  color: value ? FN.signal : FN.fill,
                  borderRadius: BorderRadius.circular(13),
                )
              : BoxDecoration(
                  color: value ? FN.signal : Colors.transparent,
                  border: Border.all(color: fg, width: 1.5),
                ),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: clean ? 20 : 18,
            height: clean ? 20 : 18,
            decoration: clean
                ? BoxDecoration(
                    color: value ? FN.onNight : FN.cardFill,
                    shape: BoxShape.circle,
                  )
                : BoxDecoration(color: fg),
          ),
        ),
      ),
    );
  }
}
