import 'package:raindrop_sqlite/ddl.dart';
import 'package:raindrop_sqlite/raindrop_sqlite.dart';
import 'package:raindrop_test/conformance.dart';

void main() {
  final probe = sqliteTable('probe', UserSchema.new);
  testDriverContract(
    packageName: 'raindrop_sqlite',
    dialect: dialect,
    createDdlGenerator: SQLiteDdlGenerator.new,
    probe: probe,
  );
}
