import 'dart:typed_data';

import 'package:raindrop/raindrop.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:test/test.dart';

void main() {
  group('postgresTable', () {
    test('registers the table under the postgres dialect', () {
      expect(_samples.$.name, 'samples');
      expect(_samples.$.dialect?.name, 'postgres');
    });
  });

  group('column types', () {
    test('every column stores under its Postgres SQL type', () {
      expect(_samples.email.sqlType, 'TEXT');
      expect(_samples.tags.sqlType, 'TEXT[]');
      expect(_samples.avatar.sqlType, 'BYTEA');
      expect(_samples.age.sqlType, 'INTEGER');
      expect(_samples.rating.sqlType, 'REAL');
      expect(_samples.active.sqlType, 'BOOLEAN');
      expect(_samples.createdAt.sqlType, 'TIMESTAMP');
      expect(_samples.balance.sqlType, 'NUMERIC');
    });

    test('nullability follows the field accessor', () {
      expect(_samples.id.isNullable, isTrue);
      expect(_samples.email.isNullable, isFalse);
    });

    test('only bigInt carries a transformer', () {
      expect(_samples.balance.transformer, isA<BigIntTransformer>());
      expect(_samples.email.transformer, isNull);
      expect(_samples.active.transformer, isNull);
      expect(_samples.createdAt.transformer, isNull);
    });
  });

  group('BigIntTransformer', () {
    final transformer = BigIntTransformer();

    test('encodes a BigInt as its decimal string', () {
      expect(transformer.encode(BigInt.zero), '0');
      expect(transformer.encode(BigInt.from(-42)), '-42');
      expect(
        transformer.encode(BigInt.parse('340282366920938463463374607431')),
        '340282366920938463463374607431',
      );
    });

    test('decodes a decimal string back into a BigInt', () {
      expect(transformer.decode('0'), BigInt.zero);
      expect(transformer.decode('-42'), BigInt.from(-42));
      expect(
        transformer.decode('340282366920938463463374607431'),
        BigInt.parse('340282366920938463463374607431'),
      );
    });

    test('round-trips values exactly', () {
      final values = [
        BigInt.zero,
        BigInt.from(-1),
        BigInt.parse('-340282366920938463463374607431768211456'),
      ];
      for (final value in values) {
        expect(transformer.decode(transformer.encode(value)), value);
      }
    });
  });
}

class _Sample {
  _Sample({
    required this.email,
    required this.tags,
    required this.avatar,
    required this.age,
    required this.rating,
    required this.active,
    required this.createdAt,
    required this.balance,
    this.id,
  });

  final int? id;
  final String email;
  final List<String> tags;
  final Uint8List avatar;
  final int age;
  final double rating;
  final bool active;
  final DateTime createdAt;
  final BigInt balance;
}

class _SampleSchema extends Schema<_Sample> {
  _SampleSchema(super.$)
      : id = $.integer('id', (s) => s.id).primaryKey(autoIncrement: true),
        email = $.text('email', (s) => s.email),
        tags = $.textArray('tags', (s) => s.tags),
        avatar = $.blob('avatar', (s) => s.avatar),
        age = $.integer('age', (s) => s.age),
        rating = $.real('rating', (s) => s.rating),
        active = $.boolean('active', (s) => s.active),
        createdAt = $.dateTime('created_at', (s) => s.createdAt),
        balance = $.bigInt('balance', (s) => s.balance);

  final ColumnType<int?> id;
  final ColumnType<String> email;
  final ColumnType<List<String>> tags;
  final ColumnType<Uint8List> avatar;
  final ColumnType<int> age;
  final ColumnType<double> rating;
  final ColumnType<bool> active;
  final ColumnType<DateTime> createdAt;
  final ColumnType<BigInt> balance;

  @override
  _Sample fromRow(RowReader read) => _Sample(
        id: read(id),
        email: read(email)!,
        tags: read(tags)!,
        avatar: read(avatar)!,
        age: read(age)!,
        rating: read(rating)!,
        active: read(active)!,
        createdAt: read(createdAt)!,
        balance: read(balance)!,
      );
}

final _SampleSchema _samples = postgresTable('samples', _SampleSchema.new);
