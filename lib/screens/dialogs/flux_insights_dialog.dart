import 'package:flutter/material.dart';

/// Flux Insights introduction dialog shown on first launch of the feature.
class FluxInsightsDialog extends StatelessWidget {
  const FluxInsightsDialog({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.85;

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF4481EB),
                    Color(0xFF04BEFE),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '全新上线 Flux Insights',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '告别繁琐的手动记账。\n只需动动嘴，Flux 就能听懂你的每一笔开销。\n智能语音洞察，帮你瞬间补全消费全貌。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3A59),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '立即体验',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                child: const Text(
                  '我知道了',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
