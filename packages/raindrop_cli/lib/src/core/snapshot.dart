import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:raindrop/snapshot.dart';
import 'package:raindrop_cli/src/core/format.dart';

/// One migration's record of the schema, as stored under `migrations/meta`.
///
/// The document carries the identity and the format version; the schema
/// itself is a [SchemaSnapshot], which raindrop owns and parses.
class MigrationSnapshot {
  /// Creates a migration snapshot.
  const MigrationSnapshot({
    required this.version,
    required this.id,
    required this.prevId,
    required this.schema,
  });

  /// Creates a migration snapshot from a JSON string.
  factory MigrationSnapshot.fromJson(String json) {
    final data = checkKeys(
      jsonDecode(json) as Map<String, dynamic>,
      context: 'the snapshot',
      requiredKeys: const {'version', 'id', 'prevId', 'schema'},
    );
    final version = data['version'] as String;
    if (version != currentVersion) {
      throw FormatException(
        'Snapshot version "$version" is not the supported "$currentVersion".',
      );
    }
    return MigrationSnapshot(
      version: version,
      id: data['id'] as String,
      prevId: data['prevId'] as String,
      schema: SchemaSnapshot.fromMap(data['schema'] as Map<String, dynamic>),
    );
  }

  /// Creates a migration snapshot around a freshly built [schema].
  factory MigrationSnapshot.of(
    SchemaSnapshot schema, {
    required String id,
    required String prevId,
  }) {
    return MigrationSnapshot(
      version: currentVersion,
      id: id,
      prevId: prevId,
      schema: schema,
    );
  }

  /// The current snapshot format version.
  static const currentVersion = '1';

  /// Null UUID used for the first snapshot's prevId.
  static const nullUuid = '00000000-0000-0000-0000-000000000000';

  /// The snapshot format version.
  final String version;

  /// Unique identifier for this snapshot.
  final String id;

  /// ID of the previous snapshot (null UUID for the first snapshot).
  final String prevId;

  /// The schema this migration recorded.
  final SchemaSnapshot schema;

  /// The SQL dialect (e.g., 'postgres', 'sqlite').
  String get dialect => schema.dialect;

  /// Generates a random UUID v4.
  static String generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Set version (4) and variant bits
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '''
${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}''';
  }

  /// Loads a snapshot from a file.
  static Future<MigrationSnapshot?> load(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return null;
    }
    final content = await file.readAsString();
    return MigrationSnapshot.fromJson(content);
  }

  /// Converts the snapshot to JSON string.
  String toJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'version': version,
      'id': id,
      'prevId': prevId,
      'schema': schema.toMap(),
    });
  }

  /// Saves the snapshot to a file.
  Future<void> save(String path) async {
    final file = File(path);
    final dir = Directory(file.parent.path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await file.writeAsString(toJson());
  }

  /// Creates a copy with the given id and prevId.
  MigrationSnapshot copyWith({
    String? id,
    String? prevId,
  }) {
    return MigrationSnapshot(
      version: version,
      id: id ?? this.id,
      prevId: prevId ?? this.prevId,
      schema: schema,
    );
  }
}
