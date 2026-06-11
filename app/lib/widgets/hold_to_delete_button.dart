import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

enum HoldDeleteState { idle, armed, holding, deleting }

class HoldToDeleteButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onDelete;
  final dynamic icon;
  final Duration holdDuration;

  const HoldToDeleteButton({
    super.key,
    required this.text,
    required this.onDelete,
    this.icon,
    this.holdDuration = const Duration(seconds: 6),
  });

  @override
  State<HoldToDeleteButton> createState() => _HoldToDeleteButtonState();
}

class _HoldToDeleteButtonState extends State<HoldToDeleteButton> {
  HoldDeleteState state = HoldDeleteState.idle;

  Timer? _timer;
  double _progress = 0;

  String get _label {
    switch (state) {
      case HoldDeleteState.idle:
        return widget.text;

      case HoldDeleteState.armed:
        return "Hold button to delete credential";

      case HoldDeleteState.holding:
        return "[${(_progress * 100).toInt()}%] This action is irreversible ";

      case HoldDeleteState.deleting:
        return "";
    }
  }

  void _armDelete() {
    if (state == HoldDeleteState.deleting) return;

    setState(() {
      state = HoldDeleteState.armed;
    });
  }

  void _startHolding() {
    if (state != HoldDeleteState.armed) return;

    const tickMs = 50;
    final totalMs = widget.holdDuration.inMilliseconds;

    setState(() {
      state = HoldDeleteState.holding;
      _progress = 0;
    });

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: tickMs), (
      timer,
    ) async {
      if (!mounted) return;

      setState(() {
        _progress += tickMs / totalMs;
      });

      if (_progress >= 1) {
        timer.cancel();

        setState(() {
          _progress = 1;
          state = HoldDeleteState.deleting;
        });

        try {
          await widget.onDelete();
        } finally {
          setState(() {
            _progress = 0;
            state = HoldDeleteState.idle;
          });
        }
      }
    });
  }

  void _cancelHolding() {
    if (state != HoldDeleteState.holding) return;

    _timer?.cancel();

    setState(() {
      _progress = 0;
      state = HoldDeleteState.armed;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: state == HoldDeleteState.idle ? _armDelete : null,
      onLongPressStart: (_) => _startHolding(),
      onLongPressEnd: (_) => _cancelHolding(),
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Progress overlay
            if (state == HoldDeleteState.holding ||
                state == HoldDeleteState.deleting)
              FractionallySizedBox(
                widthFactor: _progress,
                child: Container(color: Colors.black.withAlpha(35)),
              ),

            Center(
              child: state == HoldDeleteState.deleting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state == HoldDeleteState.idle) ...[
                          HugeIcon(
                            icon:
                                widget.icon ?? HugeIcons.strokeRoundedDelete02,
                            color: Colors.white,
                            size: 20,
                            strokeWidth: 2,
                          ),
                          const SizedBox(width: 10),
                        ],

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: Text(
                            _label,
                            key: ValueKey(_label),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
