import 'dart:convert';

/// 配置自然语言解析所需的LLM和Prompt参数
class AiNlpTuningConfig {
  const AiNlpTuningConfig({
    this.modelId = 'Qwen/Qwen2.5-7B-Instruct',
    this.temperature = 0.3,
    this.maxTokens = 500,
    this.promptFilename = 'natural_language_prompt.txt',
    this.enableDateCheatSheet = true,
  });

  factory AiNlpTuningConfig.fromJson(Map<String, dynamic> json) =>
      AiNlpTuningConfig(
        modelId: json['modelId'] as String? ?? 'Qwen/Qwen2.5-7B-Instruct',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.3,
        maxTokens: json['maxTokens'] as int? ?? 500,
        promptFilename:
            json['promptFilename'] as String? ?? 'natural_language_prompt.txt',
        enableDateCheatSheet: json['enableDateCheatSheet'] as bool? ?? true,
      );

  final String modelId;
  final double temperature;
  final int maxTokens;
  final String promptFilename;
  final bool enableDateCheatSheet;

  Map<String, dynamic> toJson() => {
        'modelId': modelId,
        'temperature': temperature,
        'maxTokens': maxTokens,
        'promptFilename': promptFilename,
        'enableDateCheatSheet': enableDateCheatSheet,
      };

  AiNlpTuningConfig copyWith({
    String? modelId,
    double? temperature,
    int? maxTokens,
    String? promptFilename,
    bool? enableDateCheatSheet,
  }) =>
      AiNlpTuningConfig(
        modelId: modelId ?? this.modelId,
        temperature: temperature ?? this.temperature,
        maxTokens: maxTokens ?? this.maxTokens,
        promptFilename: promptFilename ?? this.promptFilename,
        enableDateCheatSheet: enableDateCheatSheet ?? this.enableDateCheatSheet,
      );

  @override
  String toString() => jsonEncode(toJson());
}

