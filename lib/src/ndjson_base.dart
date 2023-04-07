import 'dart:convert';

/// {@macro ndjsonparser}
///
/// {@macro ndjsonconverter}
Stream<T> parseNdjsonBytes<T>(
  Stream<List<int>>? source, {
  required T Function(Map<String, dynamic>) converter,
}) =>
    parseNdjsonBytesAsMap(source).map<T>(converter);

/// {@macro ndjsonparser}
///
/// {@template ndjsonconverter}
/// Use [converter] to convert the raw map into a data-class.
/// {@endtemplate}
Stream<T> parseNdjsonString<T>(
  Stream<String>? source, {
  required T Function(Map<String, dynamic>) converter,
}) =>
    parseNdjsonStringAsMap(source).map<T>(converter);

/// {@macro ndjsonparser}
Stream<Map<String, dynamic>> parseNdjsonBytesAsMap(Stream<List<int>>? source) =>
    parseNdjsonStringAsMap(source?.map(utf8.decode));

/// {@template ndjsonparser}
/// Parse a given ndjson [source] stream using message-framing.
///
/// If [source] is null then this function will return an empty [Stream].
/// {@endtemplate}
Stream<Map<String, dynamic>> parseNdjsonStringAsMap(
  Stream<String>? source,
) async* {
  final StringBuffer buffered = StringBuffer();

  await for (final String chunk in source ?? const Stream<String>.empty()) {
    buffered.write(chunk);

    late int i;

    while ((i = buffered.toString().indexOf('\n')) != -1) {
      final String obj = buffered.toString().substring(0, i);
      final String rest = buffered.toString().substring(i + 1);

      buffered.clear();
      buffered.write(rest);

      if (obj.isEmpty) {
        continue;
      }

      final dynamic raw = jsonDecode(obj);

      if (raw is Map<dynamic, dynamic>) {
        yield Map<String, dynamic>.from(raw);
      }
    }
  }

  // The stream ended and the last line wasn't processed.
  if (buffered.isNotEmpty) {
    try {
      final dynamic raw = jsonDecode(buffered.toString());

      buffered.clear();

      if (raw is Map<dynamic, dynamic>) {
        yield Map<String, dynamic>.from(raw);
      }
    } on FormatException {
      buffered.clear();
    }
  }
}
