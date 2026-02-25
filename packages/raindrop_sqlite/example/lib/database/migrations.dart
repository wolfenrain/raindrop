import 'package:raindrop/raindrop.dart';

/// Generated migrations. Do not edit by hand.
final migrations = [
  const Migration('0000_initial', '''
CREATE TABLE "pets" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "owner_id" INTEGER NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
  "name" TEXT NOT NULL
);

CREATE TABLE "users" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "name" TEXT NOT NULL,
  "deleted_at" INTEGER
);

CREATE INDEX "pets_owner" ON "pets" ("id");'''),
  const Migration('0001_test', '''
ALTER TABLE "users" RENAME COLUMN "deleted_at" TO "deletedAt";'''),
];
