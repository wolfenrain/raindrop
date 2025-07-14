// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

// ERROR
extension UpdateableX3<V1, V2> on (Updateable<V1>, Updateable<V2>) {
  UpdateableResult<(V1, V2)> get $ {
    return UpdateableResult([this.$1, this.$2]);
  }
}

extension UpdateableX4<V1, V2, V3> on (
  Updateable<V1>,
  Updateable<V2>,
  Updateable<V3>
) {
  UpdateableResult<(V1, V2, V3)> get $ {
    return UpdateableResult([this.$1, this.$2, this.$3]);
  }
}
