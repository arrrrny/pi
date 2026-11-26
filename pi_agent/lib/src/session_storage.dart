/// Session storage implementations.
library;

import 'dart:convert';
import 'dart:io' as io;

import 'types.dart';

/// Abstract interface for session entry storage.
abstract class SessionStorage {
  /// Initialize storage (create files/directories as needed).
  Future<void> init();

  /// Append an entry to storage.
  Future<void> appendEntry(SessionTreeEntry entry);

  /// Load all entries from storage.
  Future<List<SessionTreeEntry>> loadEntries();

  /// Find a specific entry by ID.
  Future<SessionTreeEntry?> findEntry(String id);

  /// Set the current leaf entry ID.
  Future<void> setLeafId(String? leafId);

  /// Get the current leaf entry ID.
  Future<String?> getLeafId();

  /// Set session metadata.
  Future<void> setMetadata(SessionInfo info);

  /// Get session metadata.
  Future<SessionInfo> getMetadata();

  /// Close storage and release resources.
  Future<void> close();
}

/// In-memory session storage for testing and transient sessions.
class InMemorySessionStorage implements SessionStorage {
  final List<SessionTreeEntry> _entries = [];
  String? _leafId;
  SessionInfo? _metadata;

  @override
  Future<void> init() async {}

  @override
  Future<void> appendEntry(SessionTreeEntry entry) async => _entries.add(entry);

  @override
  Future<List<SessionTreeEntry>> loadEntries() async => List.from(_entries);

  @override
  Future<SessionTreeEntry?> findEntry(String id) async {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<void> setLeafId(String? leafId) async => _leafId = leafId;

  @override
  Future<String?> getLeafId() async => _leafId;

  @override
  Future<void> setMetadata(SessionInfo info) async => _metadata = info;

  @override
  Future<SessionInfo> getMetadata() async => _metadata!;

  @override
  Future<void> close() async {
    _entries.clear();
    _leafId = null;
    _metadata = null;
  }
}

/// JSONL file-based session storage.
class JsonlSessionStorage implements SessionStorage {
  /// Path to the JSONL file backing this storage.
  final String filePath;
  List<SessionTreeEntry>? _cache;
  String? _leafId;
  SessionInfo? _metadata;

  /// Creates JSONL storage backed by the given file path.
  JsonlSessionStorage(this.filePath);

  @override
  Future<void> init() async {
    final file = io.File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await _loadFromDisk();
  }

  @override
  Future<void> appendEntry(SessionTreeEntry entry) async {
    _cache ??= [];
    _cache!.add(entry);
    _leafId = entry.id;

    final line = jsonEncode(_entryToJson(entry));
    final file = io.File(filePath);
    await file.writeAsString('$line\n', mode: io.FileMode.append);
  }

  @override
  Future<List<SessionTreeEntry>> loadEntries() async {
    _cache ??= await _loadFromDisk();
    return List.from(_cache!);
  }

  @override
  Future<SessionTreeEntry?> findEntry(String id) async {
    final entries = await loadEntries();
    for (final e in entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<void> setLeafId(String? leafId) async {
    _leafId = leafId;
    if (_metadata != null) {
      _metadata = SessionInfo(
        id: _metadata!.id,
        name: _metadata!.name,
        createdAt: _metadata!.createdAt,
        updatedAt: DateTime.now(),
        metadata: _metadata!.metadata,
      );
    }
  }

  @override
  Future<String?> getLeafId() async => _leafId;

  @override
  Future<void> setMetadata(SessionInfo info) async {
    _metadata = info;
  }

  @override
  Future<SessionInfo> getMetadata() async => _metadata!;

  @override
  Future<void> close() async {
    _cache = null;
  }

  Future<List<SessionTreeEntry>> _loadFromDisk() async {
    final file = io.File(filePath);
    if (!await file.exists()) return [];

    final lines = await file.readAsLines();
    final entries = <SessionTreeEntry>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        if (json.containsKey('_header')) {
          _metadata = SessionInfo(
            id: json['id'] as String? ?? '',
            name: json['name'] as String? ?? '',
            createdAt: DateTime.parse(json['createdAt'] as String? ??
                DateTime.now().toIso8601String()),
            updatedAt: DateTime.now(),
          );
          continue;
        }
        final entry = _entryFromJson(json);
        if (entry != null) entries.add(entry);
      } catch (_) {
        continue;
      }
    }

    if (entries.isNotEmpty) {
      _leafId ??= entries.last.id;
    }

    return entries;
  }
}

Map<String, dynamic> _entryToJson(SessionTreeEntry entry) {
  final base = {
    'id': entry.id,
    'parentId': entry.parentId,
    'timestamp': entry.timestamp.toIso8601String(),
  };

  return switch (entry) {
    MessageEntry(:final role, :final message) => {
        ...base,
        'type': 'message',
        'role': role,
        'message': _messageToJson(message),
      },
    ThinkingLevelChangeEntry(:final level) => {
        ...base,
        'type': 'thinkingLevelChange',
        'level': level.name,
      },
    ModelChangeEntry(:final provider, :final modelId) => {
        ...base,
        'type': 'modelChange',
        'provider': provider,
        'modelId': modelId,
      },
    CompactionEntry(
      :final summary,
      :final firstKeptEntryId,
      :final tokensBefore
    ) =>
      {
        ...base,
        'type': 'compaction',
        'summary': summary,
        'firstKeptEntryId': firstKeptEntryId,
        'tokensBefore': tokensBefore,
      },
    BranchSummaryEntry(:final summary) => {
        ...base,
        'type': 'branchSummary',
        'summary': summary,
      },
    LabelEntry(:final targetId, :final label) => {
        ...base,
        'type': 'label',
        'targetId': targetId,
        'label': label,
      },
    CustomEntry(:final customType, :final data) => {
        ...base,
        'type': 'custom',
        'customType': customType,
        'data': data,
      },
    CustomMessageEntry(:final customType, :final display, :final details) => {
        ...base,
        'type': 'customMessage',
        'customType': customType,
        'display': display,
        'details': details,
      },
  };
}

SessionTreeEntry? _entryFromJson(Map<String, dynamic> json) {
  final type = json['type'] as String?;
  final id = json['id'] as String;
  final parentId = json['parentId'] as String? ?? '';
  final timestamp = DateTime.parse(json['timestamp'] as String);

  return switch (type) {
    'message' => MessageEntry(
        id: id,
        parentId: parentId,
        timestamp: timestamp,
        role: json['role'] as String? ?? 'user',
        message: _messageFromJson(json['message'] as Map<String, dynamic>?),
      ),
    'thinkingLevelChange' => ThinkingLevelChangeEntry(
        id: id,
        parentId: parentId,
        timestamp: timestamp,
        level: ThinkingLevel.values.firstWhere(
          (e) => e.name == json['level'],
          orElse: () => ThinkingLevel.off,
        ),
      ),
    'modelChange' => ModelChangeEntry(
        id: id,
        parentId: parentId,
        timestamp: timestamp,
        provider: json['provider'] as String,
        modelId: json['modelId'] as String,
      ),
    'compaction' => CompactionEntry(
        id: id,
        parentId: parentId,
        timestamp: timestamp,
        summary: json['summary'] as String,
        firstKeptEntryId: json['firstKeptEntryId'] as String,
        tokensBefore: json['tokensBefore'] as int,
      ),
    'branchSummary' => BranchSummaryEntry(
        id: id,
        parentId: parentId,
        timestamp: timestamp,
        summary: json['summary'] as String,
      ),
    'label' => LabelEntry(
        id: id,
        parentId: parentId,
        timestamp: timestamp,
        targetId: json['targetId'] as String,
        label: json['label'] as String?,
      ),
    'custom' => CustomEntry(
        id: id,
        parentId: parentId,
        timestamp: timestamp,
        customType: json['customType'] as String,
        data: json['data'] as Map<String, dynamic>?,
      ),
    _ => null,
  };
}

// --- Message serialization (full round-trip for durable recovery) ---

Map<String, dynamic> _messageToJson(AgentMessage message) => switch (message) {
      UserMessage(:final content) => {
          'kind': 'user',
          'content': content.map(_contentBlockToJson).toList(),
        },
      AssistantMessage(
        :final id,
        :final content,
        :final stopReason,
        :final errorMessage,
        :final usage,
      ) =>
        {
          'kind': 'assistant',
          if (id != null) 'id': id,
          'content': content.map(_contentBlockToJson).toList(),
          if (stopReason != null) 'stopReason': stopReason.name,
          if (errorMessage != null) 'errorMessage': errorMessage,
          if (usage != null) 'usage': _usageToJson(usage),
        },
      ToolResultMessage(
        :final toolCallId,
        :final toolName,
        :final content,
        :final isError,
      ) =>
        {
          'kind': 'toolResult',
          'toolCallId': toolCallId,
          'toolName': toolName,
          'content': content.map(_contentBlockToJson).toList(),
          'isError': isError,
        },
      CustomMessage(:final type, :final data, :final display) => {
          'kind': 'custom',
          'type': type,
          'data': data,
          'display': display,
        },
    };

AgentMessage _messageFromJson(Map<String, dynamic>? json) {
  if (json == null) return UserMessage.text('');
  final rawContent = json['content'] as List<dynamic>? ?? const [];
  final content = rawContent
      .whereType<Map<String, dynamic>>()
      .map((e) => _contentBlockFromJson(e))
      .toList();

  switch (json['kind']) {
    case 'assistant':
      return AssistantMessage(
        id: json['id'] as String?,
        content: content,
        stopReason: _stopReasonFromName(json['stopReason'] as String?),
        errorMessage: json['errorMessage'] as String?,
        usage: json['usage'] == null
            ? null
            : _usageFromJson(json['usage'] as Map<String, dynamic>),
      );
    case 'toolResult':
      return ToolResultMessage(
        toolCallId: json['toolCallId'] as String? ?? '',
        toolName: json['toolName'] as String? ?? '',
        content: content.whereType<ContentBlock>().toList(),
        isError: json['isError'] as bool? ?? false,
      );
    case 'custom':
      return CustomMessage(
        type: json['type'] as String? ?? '',
        data: json['data'] == null
            ? const {}
            : Map<String, dynamic>.from(json['data'] as Map<String, dynamic>),
        display: json['display'] as String? ?? '',
      );
    case 'user':
    default:
      return UserMessage(content: content.whereType<ContentBlock>().toList());
  }
}

Map<String, dynamic> _contentBlockToJson(dynamic block) => switch (block) {
      TextBlock(:final text) => {'type': 'text', 'text': text},
      ImageBlock(:final base64Data, :final mediaType) => {
          'type': 'image',
          'base64Data': base64Data,
          'mediaType': mediaType,
        },
      ToolCallBlock(
        :final id,
        :final name,
        :final arguments,
        :final argumentsError
      ) =>
        {
          'type': 'toolCall',
          'id': id,
          'name': name,
          'arguments': arguments,
          if (argumentsError != null) 'argumentsError': argumentsError,
        },
      ThinkingBlock(:final text) => {'type': 'thinking', 'text': text},
      _ => const {'type': 'text', 'text': ''},
    };

dynamic _contentBlockFromJson(Map<String, dynamic> json) =>
    switch (json['type']) {
      'image' => ImageBlock(
          base64Data: json['base64Data'] as String? ?? '',
          mediaType: json['mediaType'] as String? ?? 'image/png',
        ),
      'toolCall' => ToolCallBlock(
          id: json['id'] as String? ?? '',
          name: json['name'] as String? ?? '',
          arguments: json['arguments'] == null
              ? const {}
              : Map<String, dynamic>.from(
                  json['arguments'] as Map<String, dynamic>),
          argumentsError: json['argumentsError'] as String?,
        ),
      'thinking' => ThinkingBlock(json['text'] as String? ?? ''),
      'text' => TextBlock(json['text'] as String? ?? ''),
      _ => TextBlock(json['text'] as String? ?? ''),
    };

Map<String, dynamic> _usageToJson(Usage usage) => {
      'inputTokens': usage.inputTokens,
      'outputTokens': usage.outputTokens,
      if (usage.cacheCreationInputTokens != null)
        'cacheCreationInputTokens': usage.cacheCreationInputTokens,
      if (usage.cacheReadInputTokens != null)
        'cacheReadInputTokens': usage.cacheReadInputTokens,
    };

Usage _usageFromJson(Map<String, dynamic> json) => Usage(
      inputTokens: json['inputTokens'] as int? ?? 0,
      outputTokens: json['outputTokens'] as int? ?? 0,
      cacheCreationInputTokens: json['cacheCreationInputTokens'] as int?,
      cacheReadInputTokens: json['cacheReadInputTokens'] as int?,
    );

StopReason? _stopReasonFromName(String? name) {
  if (name == null) return null;
  for (final r in StopReason.values) {
    if (r.name == name) return r;
  }
  return null;
}
