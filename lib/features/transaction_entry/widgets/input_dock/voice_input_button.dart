import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 语音输入按钮组件
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    required this.onVoiceInput,
    super.key,
    this.enabled = true,
  });
  final ValueChanged<String> onVoiceInput;
  final bool enabled;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late final stt.SpeechToText _speechToText;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  bool _isListening = false;
  String _lastRecognizedText = '';

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // 脉冲动画用于录音状态
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _initializeSpeechToText();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initializeSpeechToText() async {
    try {
      final available = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      if (!available) {
        print('语音识别不可用');
      }
    } catch (e) {
      print('语音识别初始化失败: $e');
    }
  }

  void _onSpeechStatus(String status) {
    if (status == 'listening') {
      setState(() => _isListening = true);
      _animationController.repeat(reverse: true);
    } else if (status == 'notListening') {
      setState(() => _isListening = false);
      _animationController.stop();
      _animationController.value = 0.0;
    }
  }

  void _onSpeechError(Object error) {
    print('语音识别错误: $error');
    setState(() => _isListening = false);
    _animationController.stop();
    _animationController.value = 0.0;

    // 显示错误提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('语音识别失败，请检查麦克风权限'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleListening() async {
    if (!widget.enabled) return;

    if (_isListening) {
      await _speechToText.stop();
      if (_lastRecognizedText.isNotEmpty) {
        widget.onVoiceInput(_lastRecognizedText);
        _lastRecognizedText = '';
      }
    } else {
      await _speechToText.listen(
        onResult: (result) {
          setState(() {
            _lastRecognizedText = result.recognizedWords;
          });
        },
        localeId: 'zh_CN', // 中文识别
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEnabled = widget.enabled && _speechToText.isAvailable;

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
      builder: (context, child) {
        final scale =
            _isListening ? _pulseAnimation.value : _scaleAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isListening
                  ? Colors.red.withValues(alpha: 0.8)
                  : isEnabled
                      ? colorScheme.secondaryContainer
                      : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: _isListening
                  ? Border.all(
                      color: Colors.red,
                      width: 2,
                    )
                  : null,
              boxShadow: _isListening
                  ? [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              onPressed: isEnabled ? _toggleListening : null,
              icon: Icon(
                _isListening ? Icons.mic_off : Icons.mic,
                color: _isListening
                    ? Colors.white
                    : isEnabled
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
              tooltip: _isListening ? '停止录音' : '语音输入',
            ),
          ),
        );
      },
    );
  }
}
