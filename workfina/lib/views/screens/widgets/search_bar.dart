import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workfina/theme/app_theme.dart';

class GlobalSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final List<String>? hints;
  final EdgeInsets padding;

  const GlobalSearchBar({
    super.key,
    required this.onSearch,
    this.hints,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
  });

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar>
    with TickerProviderStateMixin {
  late final TextEditingController _controller;
  late final ValueNotifier<String> _animatedHint;
  

  Timer? _hintTimer;
  Timer? _typeTimer;
  Timer? _debounce;

  int _hintIndex = 0;
  int _charIndex = 0;

  late final List<String> _hints;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _animatedHint = ValueNotifier('');

    // Add listener to rebuild when text changes
    _controller.addListener(() {
      setState(() {});
    });

    _hints =
        widget.hints ??
        const [
          'candidate',
          'city',
          'state',
          'department',
          'IT',
          'religion',
          'Hindu',
        ];

    _startHintRotation();
  }

  void _startHintRotation() {
    _startTypewriter(_hints.first);

    _hintTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _hintIndex = (_hintIndex + 1) % _hints.length;
      _startTypewriter(_hints[_hintIndex]);
    });
  }

  void _startTypewriter(String text) {
    _typeTimer?.cancel();
    _charIndex = 0;
    _animatedHint.value = '';

    _typeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (_charIndex < text.length) {
        _animatedHint.value += text[_charIndex];
        _charIndex++;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _typeTimer?.cancel();
    _debounce?.cancel();
    _controller.dispose();
    _animatedHint.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            SvgPicture.asset(
              'assets/svgs/search.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),

            Text(
              'Search ',
              style: AppTheme.getBodyStyle(
                context,
                color: Colors.white,
                fontSize: 15,
              ),
            ),

            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _animatedHint,
                builder: (_, hintText, __) {
                  return TextField(
                    controller: _controller,
                    cursorColor: Colors.white,
                    style: AppTheme.getBodyStyle(
                      context,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(
                        const Duration(milliseconds: 300),
                        () => widget.onSearch(value.toLowerCase()),
                      );
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: '"$hintText"',
                      hintStyle: AppTheme.getBodyStyle(
                        context,
                        color: Colors.white,
                        fontSize: 15,
                      ).copyWith(fontFamily: 'SFMono'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  );
                },
              ),
            ),

            // Close button - only show when text is present
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onSearch('');
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),

            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
