import 'ndjson_base.dart' as base;

extension ParseNdJsonBytes on Stream<List<int>>? {
  /// {@macro ndjsonparser}
  ///
  /// {@macro ndjsonconverter}
  Stream<T> parseNdjsonBytes<T>({
    required T Function(Map<String, dynamic>) converter,
  }) =>
      base.parseNdjsonBytesAsMap(this).map<T>(converter);

  /// {@macro ndjsonparser}
  Stream<Map<String, dynamic>> parseNdjsonBytesAsMap() =>
      base.parseNdjsonBytesAsMap(this);
}

extension ParseNdJsonString on Stream<String>? {
  /// {@macro ndjsonparser}
  ///
  /// {@macro ndjsonconverter}
  Stream<T> parseNdjsonString<T>({
    required T Function(Map<String, dynamic>) converter,
  }) =>
      base.parseNdjsonString(this, converter: converter);

  /// {@macro ndjsonparser}
  Stream<Map<String, dynamic>> parseNdjsonStringAsMap() =>
      base.parseNdjsonStringAsMap(this);
}
