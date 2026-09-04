## 0.1.0

> Note: This release has breaking changes.

 - **REFACTOR**: nullable-aware columns, projection joins, and a lot more. ([c2970d1d](https://github.com/wolfenrain/raindrop/commit/c2970d1d1d39ed2749b5443cd2cf798a6b6f4a1c))
 - **REFACTOR**: remove `.$` column by introducing a `ColumnOr` solution. ([91fc4305](https://github.com/wolfenrain/raindrop/commit/91fc43051be9d53e994b1ca2db0432082dba8b2c))
 - **REFACTOR**: make fakes obsolute and clean up the schema API. ([b78ceca1](https://github.com/wolfenrain/raindrop/commit/b78ceca18205697156e198312be97022eca71abc))
 - **REFACTOR**: simply dialect logic across packages. ([7f9a7d4c](https://github.com/wolfenrain/raindrop/commit/7f9a7d4ca16436b93dd0bb0d5206af5ecbf87c12))
 - **FIX**: render capped SQLite writes as a key subquery ([#31](https://github.com/wolfenrain/raindrop/issues/31)). ([799b2490](https://github.com/wolfenrain/raindrop/commit/799b2490d2351a5c2b393059ea53faef046a4bb5))
 - **FIX**: properly detect if a column is nullable. ([f35b9c46](https://github.com/wolfenrain/raindrop/commit/f35b9c46224c4367c5bb8113b069800c9332985d))
 - **FIX**: make column names valid in SQL. ([59e88583](https://github.com/wolfenrain/raindrop/commit/59e885833b0b692cd98053255aa03b103a23dd57))
 - **FIX**: make update actually work. ([4debcc23](https://github.com/wolfenrain/raindrop/commit/4debcc23cc280a35a5c8bb67946876420c12a78a))
 - **FIX**: try to imporve updatable. ([f7a7dbbe](https://github.com/wolfenrain/raindrop/commit/f7a7dbbeca9e82ecaaa8b50a813690241935824b))
 - **FEAT**: add portable string functions ([#49](https://github.com/wolfenrain/raindrop/issues/49)). ([fb19b1a1](https://github.com/wolfenrain/raindrop/commit/fb19b1a1247f0ea88a0295644449b444fbfcda81))
 - **FEAT**: rework insert conflict handling into a chained upsert API ([#48](https://github.com/wolfenrain/raindrop/issues/48)). ([12acfc57](https://github.com/wolfenrain/raindrop/commit/12acfc57172ddd507b44e4f583c6d438a8d497b3))
 - **FEAT**: add `BETWEEN` ([#47](https://github.com/wolfenrain/raindrop/issues/47)). ([b4000fad](https://github.com/wolfenrain/raindrop/commit/b4000fadc8fd422354d4758814229e3c6fd53d37))
 - **FEAT**: add `CASE` expressions ([#46](https://github.com/wolfenrain/raindrop/issues/46)). ([fa694c37](https://github.com/wolfenrain/raindrop/commit/fa694c37c1b440abad872e9aafac64dc1fa36195))
 - **FEAT**: support multiple `GROUP BY` terms ([#45](https://github.com/wolfenrain/raindrop/issues/45)). ([f28fa64c](https://github.com/wolfenrain/raindrop/commit/f28fa64c67727d5039ff9115427f389031a80bdb))
 - **FEAT**: deepen the driver conformance suite ([#43](https://github.com/wolfenrain/raindrop/issues/43)). ([37c44597](https://github.com/wolfenrain/raindrop/commit/37c44597a34eebb76c97ce25d809857778e09b2a))
 - **FEAT**: let `dateTime`, `boolean` and `bigInt` columns declare a default value ([#32](https://github.com/wolfenrain/raindrop/issues/32)). ([cca8f5fe](https://github.com/wolfenrain/raindrop/commit/cca8f5feabe85c2af8312cd0fa2b56810bc9c152))
 - **FEAT**: add basic foreign key support. ([45cbd8e1](https://github.com/wolfenrain/raindrop/commit/45cbd8e1c1c5cd37ab2adcd6984b2efc0bda9d4f))
 - **FEAT**: added sql DDL generation and a basic CLI to accomidate it + improvements to the runtime API. ([aeef771a](https://github.com/wolfenrain/raindrop/commit/aeef771a03850aa99eab66dc8d7adf8e0b6fac66))
 - **FEAT**: support more custom types like lists. ([2b27182d](https://github.com/wolfenrain/raindrop/commit/2b27182dcfcd5845afac9bed1293db5781bad037))
 - **FEAT**: support more custom types like lists. ([0d05a312](https://github.com/wolfenrain/raindrop/commit/0d05a312ca37f257ca9190bf8c4499b8ea3e1cb3))
 - **FEAT**: add `postgres` support. ([e9cf12a2](https://github.com/wolfenrain/raindrop/commit/e9cf12a2959832e295f28d5bcce24ee4afa00fe1))
 - **DOCS**: added READMEs. ([81b8c019](https://github.com/wolfenrain/raindrop/commit/81b8c019642efeb22e9c0590f6f102ea409ae29f))
 - **BREAKING** **REFACTOR**: simplify delegate connection handling and lower dependency constraints. ([870b5c3a](https://github.com/wolfenrain/raindrop/commit/870b5c3ab11732846e4ef42ebc818ddb3bebd1e0))
 - **BREAKING** **FEAT**: give drivers their own migration storage ([#51](https://github.com/wolfenrain/raindrop/issues/51)). ([7114aad3](https://github.com/wolfenrain/raindrop/commit/7114aad3fb7f1dffbe3d917b10da3f4c2c406bbb))

