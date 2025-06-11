// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars

import 'package:raindrop/raindrop.dart';

extension ConvertResult<R> on SelectableResult<R> {
  R read(Map<String, dynamic> data, AliasRegistry registry) {
    switch(selected.length) {
      case 2:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
        ) as R;
      case 3:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
        ) as R;
      case 4:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
        ) as R;
      case 5:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
        ) as R;
      case 6:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
        ) as R;
      case 7:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
        ) as R;
      case 8:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
        ) as R;
      case 9:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
        ) as R;
      case 10:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
        ) as R;
      case 11:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
          Selectable.read(selected[10], data, registry),
        ) as R;
      case 12:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
          Selectable.read(selected[10], data, registry),
          Selectable.read(selected[11], data, registry),
        ) as R;
      case 13:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
          Selectable.read(selected[10], data, registry),
          Selectable.read(selected[11], data, registry),
          Selectable.read(selected[12], data, registry),
        ) as R;
      case 14:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
          Selectable.read(selected[10], data, registry),
          Selectable.read(selected[11], data, registry),
          Selectable.read(selected[12], data, registry),
          Selectable.read(selected[13], data, registry),
        ) as R;
      case 15:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
          Selectable.read(selected[10], data, registry),
          Selectable.read(selected[11], data, registry),
          Selectable.read(selected[12], data, registry),
          Selectable.read(selected[13], data, registry),
          Selectable.read(selected[14], data, registry),
        ) as R;
      case 16:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
          Selectable.read(selected[10], data, registry),
          Selectable.read(selected[11], data, registry),
          Selectable.read(selected[12], data, registry),
          Selectable.read(selected[13], data, registry),
          Selectable.read(selected[14], data, registry),
          Selectable.read(selected[15], data, registry),
        ) as R;
      case 17:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
          Selectable.read(selected[10], data, registry),
          Selectable.read(selected[11], data, registry),
          Selectable.read(selected[12], data, registry),
          Selectable.read(selected[13], data, registry),
          Selectable.read(selected[14], data, registry),
          Selectable.read(selected[15], data, registry),
          Selectable.read(selected[16], data, registry),
        ) as R;
      case 18:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
          Selectable.read(selected[10], data, registry),
          Selectable.read(selected[11], data, registry),
          Selectable.read(selected[12], data, registry),
          Selectable.read(selected[13], data, registry),
          Selectable.read(selected[14], data, registry),
          Selectable.read(selected[15], data, registry),
          Selectable.read(selected[16], data, registry),
          Selectable.read(selected[17], data, registry),
        ) as R;
      case 19:
        return (
          Selectable.read(selected[0], data, registry),
          Selectable.read(selected[1], data, registry),
          Selectable.read(selected[2], data, registry),
          Selectable.read(selected[3], data, registry),
          Selectable.read(selected[4], data, registry),
          Selectable.read(selected[5], data, registry),
          Selectable.read(selected[6], data, registry),
          Selectable.read(selected[7], data, registry),
          Selectable.read(selected[8], data, registry),
          Selectable.read(selected[9], data, registry),
          Selectable.read(selected[10], data, registry),
          Selectable.read(selected[11], data, registry),
          Selectable.read(selected[12], data, registry),
          Selectable.read(selected[13], data, registry),
          Selectable.read(selected[14], data, registry),
          Selectable.read(selected[15], data, registry),
          Selectable.read(selected[16], data, registry),
          Selectable.read(selected[17], data, registry),
          Selectable.read(selected[18], data, registry),
        ) as R;
      default:
        throw UnsupportedError('${selected.length}');
    }
  }
}
