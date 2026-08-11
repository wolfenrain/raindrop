import 'dart:isolate';

import 'package:raindrop_postgres/ddl.dart';

export 'package:raindrop/ddl.dart';

export 'src/postgres_ddl.dart';

/// The CLI's DDL entrypoint: serves this driver's [DdlGenerator] over the
/// isolate command protocol.
void main(List<String> args, SendPort sendPort) =>
    serveDdlGenerator(const PostgresDdlGenerator(), sendPort);
