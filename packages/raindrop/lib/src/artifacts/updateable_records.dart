// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

// ERROR
extension UpdateableX3<S extends Schema<S>, V1, V2> on (
  Updateable<S, V1>,
  Updateable<S, V2>
) {
  UpdateableResult<S, (V1, V2)> get $ {
    return UpdateableResult([this.$1, this.$2]);
  }
}

extension UpdateableX4<S extends Schema<S>, V1, V2, V3> on (
  Updateable<S, V1>,
  Updateable<S, V2>,
  Updateable<S, V3>
) {
  UpdateableResult<S, (V1, V2, V3)> get $ {
    return UpdateableResult([this.$1, this.$2, this.$3]);
  }
}
