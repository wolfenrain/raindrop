// GENERATED CODE — DO NOT EDIT BY HAND.
// Run `dart run tools/generate_the_magic.dart` to regenerate.
// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'package:raindrop/raindrop.dart';

extension UpdateableColumnsOn<S extends Schema<RR>, RR, R> on UpdateSettingBuilder<S, RR, R> {
  /// Set columns to update.
  UpdateWhereBuilder<S, RR, R> set(Updateable<dynamic> u0, [Updateable<dynamic>? u1, Updateable<dynamic>? u2, Updateable<dynamic>? u3, Updateable<dynamic>? u4, Updateable<dynamic>? u5, Updateable<dynamic>? u6, Updateable<dynamic>? u7, Updateable<dynamic>? u8, Updateable<dynamic>? u9, Updateable<dynamic>? u10, Updateable<dynamic>? u11, Updateable<dynamic>? u12, Updateable<dynamic>? u13, Updateable<dynamic>? u14, Updateable<dynamic>? u15, Updateable<dynamic>? u16, Updateable<dynamic>? u17, Updateable<dynamic>? u18, Updateable<dynamic>? u19]) {
    final updates = <Updateable<dynamic>?>[u0, u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12, u13, u14, u15, u16, u17, u18, u19].whereType<Updateable<dynamic>>().toList();
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#set: UpdateableResult<List<Object?>>(updates)}),
    );
  }

  /// Set columns from a list or iterable (e.g. built dynamically, or more than
  /// [set]'s positional limit). Must be non-empty.
  ///
  /// ```dart
  /// db.update(users).setAll([users.name.to('new'), users.age.to(25)]);
  /// ```
  UpdateWhereBuilder<S, RR, R> setAll(Iterable<Updateable<dynamic>> updates) {
    final list = List<Updateable>.from(updates);
    if (list.isEmpty) {
      throw ArgumentError.value(updates, 'updates', 'must not be empty');
    }
    return UpdateWhereBuilder(
      executor,
      config: config.copyWith({#set: UpdateableResult<List<Object?>>(list)}),
    );
  }
}

