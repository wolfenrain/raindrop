import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:raindrop_cli/raindrop_cli.dart';
import 'package:test/test.dart';

void main() {
  group('MigrationJournal', () {
    test('an absent file loads as an empty journal', () async {
      final journal = await MigrationJournal.load('/nowhere/_journal.json');
      expect(journal.entries, isEmpty);
      expect(journal.dialect, isEmpty);
      expect(journal.nextIndex, 0);
      expect(journal.previousId, SchemaSnapshot.nullUuid);
    });

    test('addEntry advances index and previousId', () {
      final journal = MigrationJournal.empty().addEntry(
        JournalEntry(
          idx: 0,
          version: '1',
          when: 1700000000000,
          tag: '0000_init',
          snapshotId: 'snap-0',
        ),
      );

      expect(journal.nextIndex, 1);
      expect(journal.previousId, 'snap-0');
      expect(journal.entries.single.snapshotFileName, '0000_snapshot.json');
    });

    test('round-trips through JSON and disk', () async {
      final dir = Directory.systemTemp.createTempSync('journal_test_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final path = p.join(dir.path, 'meta', '_journal.json');

      final journal = MigrationJournal.empty().addEntry(
        JournalEntry(
          idx: 0,
          version: '1',
          when: 1700000000000,
          tag: '0000_init',
          snapshotId: 'snap-0',
        ),
      );
      await journal.save(path);
      final loaded = await MigrationJournal.load(path);
      expect(loaded.toJson(), journal.toJson());
    });
  });
}
