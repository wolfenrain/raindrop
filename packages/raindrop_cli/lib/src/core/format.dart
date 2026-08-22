/// Validates that [data] holds exactly the keys a meta file format declares,
/// returning it for further reading.
///
/// Any other key means the file was written by a different version of the
/// raindrop tooling. Silently ignoring it is how a renamed key becomes a
/// phantom schema change, so the parse fails instead, and a missing
/// [requiredKeys] entry fails for the same reason.
Map<String, dynamic> checkKeys(
  Map<String, dynamic> data, {
  required String context,
  required Set<String> requiredKeys,
  Set<String> optionalKeys = const {},
}) {
  for (final key in data.keys) {
    if (!requiredKeys.contains(key) && !optionalKeys.contains(key)) {
      throw FormatException(
        'Unknown key "$key" in $context, was the file written by a '
        'different version of the raindrop tooling?',
      );
    }
  }
  for (final key in requiredKeys) {
    if (!data.containsKey(key)) {
      throw FormatException('Missing key "$key" in $context.');
    }
  }
  return data;
}
