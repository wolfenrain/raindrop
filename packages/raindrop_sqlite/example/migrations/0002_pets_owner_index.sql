DROP INDEX "pets_owner";
CREATE INDEX "pets_owner" ON "pets" ("owner_id", "id");