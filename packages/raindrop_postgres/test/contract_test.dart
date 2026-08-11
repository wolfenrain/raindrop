import 'package:raindrop_postgres/ddl.dart';
import 'package:raindrop_postgres/raindrop_postgres.dart';
import 'package:raindrop_test/conformance.dart';

void main() {
  final probe = postgresTable('probe', UserSchema.new);
  testDriverContract(
    packageName: 'raindrop_postgres',
    createDdlGenerator: PostgresDdlGenerator.new,
    probe: probe,
  );
}
