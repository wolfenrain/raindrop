import 'package:raindrop/raindrop.dart';

/// Generated migrations. Do not edit by hand.
final migrations = [
  const Migration('0000_initial', '''
CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "deleted_at" TIMESTAMP
);

CREATE TABLE "pets" (
  "id" SERIAL PRIMARY KEY,
  "owner_id" INTEGER NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL
);'''),
];
