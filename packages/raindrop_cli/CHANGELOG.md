## 0.1.0

> Note: This release has breaking changes.

 - **REFACTOR**: nullable-aware columns, projection joins, and a lot more. ([c2970d1d](https://github.com/wolfenrain/raindrop/commit/c2970d1d1d39ed2749b5443cd2cf798a6b6f4a1c))
 - **REFACTOR**: remove function to add args. ([c6f8a39d](https://github.com/wolfenrain/raindrop/commit/c6f8a39d0deea519860a9c45006a11d623efcc91))
 - **REFACTOR**: clean up comment and output. ([5b9ac078](https://github.com/wolfenrain/raindrop/commit/5b9ac0785365cc0d051e6f151dbbaa3a5b8c2d78))
 - **FIX**: reject unknown or missing keys in snapshot and journal files ([#44](https://github.com/wolfenrain/raindrop/issues/44)). ([9911a31e](https://github.com/wolfenrain/raindrop/commit/9911a31ebfd00fea29311f3e6c4e960ba5483d3f))
 - **FIX**: proper version handling in cli ([#42](https://github.com/wolfenrain/raindrop/issues/42)). ([e45b025c](https://github.com/wolfenrain/raindrop/commit/e45b025c356e25930e83356aee75190326152a86))
 - **FIX**: build generated package: URIs with forward slashes ([#35](https://github.com/wolfenrain/raindrop/issues/35)). ([8a30a582](https://github.com/wolfenrain/raindrop/commit/8a30a582dc1f6e31d2cb6326e7d40da6b8a45271))
 - **FIX**: reordering a table's indexes is not a schema change ([#37](https://github.com/wolfenrain/raindrop/issues/37)). ([69088e17](https://github.com/wolfenrain/raindrop/commit/69088e178f62d1aca5cf8fc38b78232140072376))
 - **FIX**: properly transform column values when used in queries. ([4cbf2f59](https://github.com/wolfenrain/raindrop/commit/4cbf2f59d9331cff7a57716e2fe8e6760db499f2))
 - **FIX**: update analyzer. ([71c906cc](https://github.com/wolfenrain/raindrop/commit/71c906ccb191c6ff72bec264c7ad7e35e55b1df9))
 - **FIX**: properly detect if a column is nullable. ([f35b9c46](https://github.com/wolfenrain/raindrop/commit/f35b9c46224c4367c5bb8113b069800c9332985d))
 - **FEAT**: add optional config flags to command. ([9527a4dd](https://github.com/wolfenrain/raindrop/commit/9527a4dd29a0b7a666202554e178c0af62f4ffab))
 - **FEAT**: clean up code. ([9b8bed9b](https://github.com/wolfenrain/raindrop/commit/9b8bed9b09c0b3f13413d28e5534208703f68651))
 - **FEAT**: add optional config flags to command. ([ac94b721](https://github.com/wolfenrain/raindrop/commit/ac94b72178532b4bf00a96ef4732a74944097aed))
 - **FEAT**: return early when no migration changes are detected. ([034cf58f](https://github.com/wolfenrain/raindrop/commit/034cf58f161f163810b312bc7fa27a68dd181b83))
 - **FEAT**: add option to tag migration with timestamp. ([eb4b50ab](https://github.com/wolfenrain/raindrop/commit/eb4b50abd5f48287c611945771fa99f552a2ee4e))
 - **FEAT**: support Dart based migrations. ([ba555b30](https://github.com/wolfenrain/raindrop/commit/ba555b30ee5e871efb87793c736a1ec3a30e59c0))
 - **FEAT**: add basic foreign key support. ([45cbd8e1](https://github.com/wolfenrain/raindrop/commit/45cbd8e1c1c5cd37ab2adcd6984b2efc0bda9d4f))
 - **FEAT**: added sql DDL generation and a basic CLI to accomidate it + improvements to the runtime API. ([aeef771a](https://github.com/wolfenrain/raindrop/commit/aeef771a03850aa99eab66dc8d7adf8e0b6fac66))
 - **DOCS**: added READMEs. ([81b8c019](https://github.com/wolfenrain/raindrop/commit/81b8c019642efeb22e9c0590f6f102ea409ae29f))
 - **BREAKING** **FEAT**: give drivers their own migration storage ([#51](https://github.com/wolfenrain/raindrop/issues/51)). ([7114aad3](https://github.com/wolfenrain/raindrop/commit/7114aad3fb7f1dffbe3d917b10da3f4c2c406bbb))

