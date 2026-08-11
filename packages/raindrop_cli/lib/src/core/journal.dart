import 'dart:convert';
import 'dart:io';

/// Represents the migration journal that tracks all applied migrations.
///
/// Migration metadata is stored in a `_journal.json` file within the meta
/// directory.
class MigrationJournal {
  /// Creates a journal with the given [version], [dialect], and [entries].
  const MigrationJournal({
    required this.version,
    required this.dialect,
    required this.entries,
  });

  /// Creates an empty journal.
  ///
  /// The dialect is unknown until the first snapshot is taken, writing the
  /// first entry stamps the snapshot's dialect.
  factory MigrationJournal.empty() {
    return const MigrationJournal(
      version: currentVersion,
      dialect: '',
      entries: [],
    );
  }

  /// Creates a journal from JSON string.
  factory MigrationJournal.fromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return MigrationJournal(
      version: data['version'] as String,
      dialect: data['dialect'] as String,
      entries: [
        for (final entry in (data['entries'] as List<dynamic>))
          JournalEntry.fromMap(entry as Map<String, dynamic>)
      ],
    );
  }

  /// The journal format version.
  static const currentVersion = '1';

  /// Journal format version.
  final String version;

  /// The SQL dialect (e.g., 'postgres', 'sqlite').
  final String dialect;

  /// List of migration entries.
  final List<JournalEntry> entries;

  /// Loads journal from file, or creates empty if doesn't exist.
  static Future<MigrationJournal> load(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      return MigrationJournal.empty();
    }
    final content = await file.readAsString();
    return MigrationJournal.fromJson(content);
  }

  /// Gets the next migration index.
  int get nextIndex => entries.isEmpty ? 0 : entries.last.idx + 1;

  /// Gets the previous snapshot ID (null UUID if no entries).
  String get previousId {
    if (entries.isEmpty) {
      return '00000000-0000-0000-0000-000000000000';
    }
    return entries.last.snapshotId;
  }

  /// Creates a new journal with an added entry.
  MigrationJournal addEntry(JournalEntry entry) {
    return MigrationJournal(
      version: version,
      dialect: dialect,
      entries: [...entries, entry],
    );
  }

  /// Converts the journal to JSON string.
  String toJson() {
    return const JsonEncoder.withIndent('  ').convert({
      'version': version,
      'dialect': dialect,
      'entries': entries.map((e) => e.toMap()).toList(),
    });
  }

  /// Saves the journal to a file.
  Future<void> save(String path) async {
    final file = File(path);
    final dir = Directory(file.parent.path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    await file.writeAsString(toJson());
  }
}

/// Represents a single entry in the migration journal.
class JournalEntry {
  /// Creates an entry for a single generated migration.
  const JournalEntry({
    required this.idx,
    required this.version,
    required this.when,
    required this.tag,
    required this.snapshotId,
  });

  /// Creates an entry from a map.
  factory JournalEntry.fromMap(Map<String, dynamic> data) {
    return JournalEntry(
      idx: data['idx'] as int,
      version: data['version'] as String,
      when: data['when'] as int,
      tag: data['tag'] as String,
      snapshotId: data['snapshotId'] as String,
    );
  }

  /// The migration index (0-based).
  final int idx;

  /// The schema version at this migration.
  final String version;

  /// Timestamp when the migration was created (milliseconds since epoch).
  final int when;

  /// The migration tag/name.
  final String tag;

  /// The snapshot ID for this migration.
  final String snapshotId;

  /// Converts the entry to a map.
  Map<String, dynamic> toMap() {
    return {
      'idx': idx,
      'version': version,
      'when': when,
      'tag': tag,
      'snapshotId': snapshotId,
    };
  }

  /// Gets the snapshot filename for this entry.
  String get snapshotFileName =>
      '${idx.toString().padLeft(4, '0')}_snapshot.json';
}
