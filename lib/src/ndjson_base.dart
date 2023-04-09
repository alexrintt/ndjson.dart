import 'dart:convert';

const bool kDefaultIgnoreEmptyLines = true;

/// {@template parseNdjsonWithConverter}
/// Parse a given ndjson [stream] using message-framing, supports [byteStream].
///
/// If both is null then this function will return an empty [Stream].
///
/// This function includes a set of [converter] options that allows automatic cast to a given type [T].
///
/// - To parse every line of the ndjson, use [converter], this callback is called whenever an ndjson event is emitted, including empty lines if [ignoreEmptyLines] is set to false.
/// - Use [whenMap] when you need to parse json objects only.
/// - Use [whenList] when you need to parse ndjson arrays only.
/// - Use [whenAny] to parse every ndjson line except empty lines.
/// - Use [whenEmptyLine] to parse empty lines specifically. Note that this function will be used only if [converter] is null.
/// - Use [whenInt], [whenDouble] to parse json numbers. Both have precedence over [whenNum] (which is used only if the value is a number and [whenInt] and [whenDouble] is not defined).
/// - Use [whenString] to parse json strings.
/// - Use [whenNull] to parse when the ndjson line is null.
///
/// Any type which the equivalent converter function is not provided, will be ignored, e.g the ndjson [stream] emits a new integer and if there's no converter that can handle this type (neither [converter], [whenAny] or [whenInt]), the value will be ignored.
/// {@endtemplate}
Stream<T> parseNdjsonWithConverter<T>({
  Stream<List<int>>? byteStream,
  Stream<String>? stream,
  T Function(NdjsonLine)? converter,
  T Function(Map<String, dynamic>)? whenMap,
  T Function(dynamic)? whenAny,
  T Function(List<dynamic>)? whenList,
  T Function(int)? whenInt,
  T Function(double)? whenDouble,
  T Function(num)? whenNum,
  T Function(String)? whenString,
  T Function(bool)? whenBool,
  T Function()? whenNull,
  T Function()? whenEmptyLine,
  bool? ignoreEmptyLines,
}) async* {
  final Stream<NdjsonLine> source = parseNdjson(
    stream: stream,
    byteStream: byteStream,
    ignoreEmptyLines:
        ignoreEmptyLines ?? converter == null && whenEmptyLine == null,
  );

  await for (final NdjsonLine line in source) {
    if (converter != null) {
      yield converter(line);
    } else if (whenEmptyLine != null && line.isEmpty) {
      yield whenEmptyLine();
    } else if (whenAny != null && line.isValidJson) {
      yield line.asObject<T>(converter: whenAny);
    } else {
      if (whenMap != null && line.isMap) {
        yield whenMap(line.asMap());
      } else if (whenList != null && line.isList) {
        yield whenList(line.asList());
      } else if (whenInt != null && line.isInt) {
        yield whenInt(line.asInt());
      } else if (whenDouble != null && line.isDouble) {
        yield whenDouble(line.asDouble());
      } else if (whenNum != null && line.isNum) {
        yield whenNum(line.asNum());
      } else if (whenString != null && line.isString) {
        yield whenString(line.asString());
      } else if (whenBool != null && line.isBool) {
        yield whenBool(line.asBool());
      } else if (whenNull != null && line.isNull) {
        yield whenNull();
      }
    }
  }
}

/// {@template parseNdjson}
/// Parse a given ndjson [stream] using message-framing, supports [byteStream].
///
/// If both is null then this function will return an empty [Stream].
///
/// The returned stream emit [NdjsonLine]s for each ndjson received event.
///
/// Use [ignoreEmptyLines] to control whether or not the returned stream should omit
/// empty lines. These empty lines are generally 'keep-alive' messages sent by the server, but if that is not your case and you want to parse these empty lines manually, set [ignoreEmptyLines] to false.
/// {@endtemplate}
Stream<NdjsonLine> parseNdjson({
  Stream<List<int>>? byteStream,
  Stream<String>? stream,
  bool ignoreEmptyLines = kDefaultIgnoreEmptyLines,
}) async* {
  Stream<String> source =
      stream ?? byteStream?.map(utf8.decode) ?? const Stream<String>.empty();

  await for (final String line in source.transform(LineSplitter())) {
    final NdjsonLine ndjsonLine = NdjsonLine(line);

    if (ndjsonLine.isEmpty && ignoreEmptyLines) {
      continue;
    }

    yield ndjsonLine;
  }
}

/// Represents a ndjson line. Following the [ndjson spec](https://github.com/ndjson/ndjson-spec#32-parsing).
class NdjsonLine {
  NdjsonLine(this.rawNdjsonLine);

  final String rawNdjsonLine;

  // Cache jsonDecode value to avoid parsing the entire json line everytime the user
  // call any getter. The [rawNdjsonLine] field is final and immutable, so the value never changes.
  dynamic _rawJsonValue;

  /// Convert the raw ndjson value to json. Be certain it is not an empty line.
  dynamic get rawJsonValue => _rawJsonValue ??= jsonDecode(rawNdjsonLine);

  /// Parse the current ndjson line as a Dart [Map].
  Map<String, dynamic> asMap() {
    return Map<String, dynamic>.from(rawJsonValue);
  }

  /// Parse the current ndjson line as an object of type [T] by providing a [converter] function.
  T asObject<T>({
    required T Function(dynamic) converter,
  }) =>
      converter(rawJsonValue);

  /// Parse current [rawJsonValue] as [num].
  num asNum() => rawJsonValue as num;

  /// Parse current [rawJsonValue] as [int].
  int asInt() => rawJsonValue as int;

  /// Parse current [rawJsonValue] as [double].
  double asDouble() => rawJsonValue as double;

  /// Parse current [rawJsonValue] as [String].
  String asString() => rawJsonValue as String;

  /// Parse current [rawJsonValue] as [bool].
  bool asBool() => rawJsonValue as bool;

  T Function(dynamic) _getDefaultConverter<T>() => (dynamic e) => e as T;

  /// Parse the current ndjson line as List. Optionally provide a [converter] function
  /// to cast the values to an also optional type [T].
  List<T> asList<T>({
    T Function(dynamic)? converter,
  }) =>
      (rawJsonValue as Iterable<dynamic>)
          .map((converter ?? _getDefaultConverter<T>()))
          .toList();

  /// Whether or not the [rawJsonValue] is a json null value.
  bool get isNull => rawJsonValue == null;

  /// Whether or not the [rawJsonValue] is a json string.
  bool get isString => rawJsonValue is String;

  /// Whether or not the [rawJsonValue] is a json boolean.
  bool get isBool => rawJsonValue is bool;

  /// Whether or not the [rawJsonValue] is a json int.
  bool get isInt => rawJsonValue is int;

  /// Whether or not the [rawJsonValue] is a json number.
  bool get isDouble => rawJsonValue is double;

  /// Whether or not the [rawJsonValue] is a json number or integer.
  bool get isNum => isInt || isDouble;

  /// Whether or not the [rawJsonValue] is a json object.
  bool get isMap => rawJsonValue is Map<dynamic, dynamic>;

  /// Whether or not the [rawJsonValue] is a json array.
  bool get isList => rawJsonValue is Iterable<dynamic>;

  /// Whether or not the [rawNdjsonLine] is an empty line.
  bool get isEmpty => rawNdjsonLine.isEmpty;

  /// Inverse of [isEmpty].
  ///
  /// Whether or not the [rawNdjsonLine] is **not** an empty line.
  bool get isNotEmpty => !isEmpty;

  /// Whether or not the [rawNdjsonLine] is following the [ndjson/ndjson-spec](1).
  ///
  /// [1]: https://github.com/ndjson/ndjson-spec.
  bool get isValid => isEmpty || isValidJson;

  /// Inverse of [isValid].
  ///
  /// Whether or not the [rawNdjsonLine] is **not** following the [ndjson/ndjson-spec](1).
  ///
  /// [1]: https://github.com/ndjson/ndjson-spec.
  bool get isInvalid => !isValid;

  /// Whether or not the [rawNdjsonLine] is a primitive json value:
  ///
  /// - number.
  /// - string.
  /// - null.
  /// - boolean.
  bool get isPrimitive => isValidJson && !isList && !isMap;

  /// Whether or not the [rawNdjsonLine] is a valid json value (number, object, array, boolean, string or null).
  ///
  /// If [rawNdjsonLine] has JSON syntax errors or is not a valid JSON (following the [JSON rfc/rfc7159](1)).
  ///
  /// [1]: https://www.rfc-editor.org/rfc/rfc7159
  bool get isValidJson {
    try {
      jsonDecode(rawNdjsonLine);
      return true;
    } on FormatException {
      return false;
    }
  }

  @override
  int get hashCode {
    return Object.hashAll(<String>[rawNdjsonLine]);
  }

  @override
  bool operator ==(Object other) {
    return other is NdjsonLine && other.rawNdjsonLine == rawNdjsonLine;
  }

  @override
  String toString() => 'NdjsonLine(rawNdjsonLine: $rawNdjsonLine)';
}
