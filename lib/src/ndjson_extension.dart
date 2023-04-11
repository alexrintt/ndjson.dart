import 'package:ndjson/ndjson.dart';

import 'ndjson_base.dart' as base;

extension ParseNdJsonBytes on Stream<List<int>>? {
  /// {@macro parseNdjson}
  Stream<NdjsonLine> parseNdjson({
    bool ignoreEmptyLines = kDefaultIgnoreEmptyLines,
  }) =>
      base.parseNdjson(
        byteStream: this,
        ignoreEmptyLines: ignoreEmptyLines,
      );

  /// {@macro parseNdjsonWithConverter}
  Stream<T> parseNdjsonWithConverter<T>({
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
  }) =>
      base.parseNdjsonWithConverter<T>(
        byteStream: this,
        converter: converter,
        whenMap: whenMap,
        whenAny: whenAny,
        whenList: whenList,
        whenInt: whenInt,
        whenDouble: whenDouble,
        whenNum: whenNum,
        whenString: whenString,
        whenBool: whenBool,
        whenNull: whenNull,
        whenEmptyLine: whenEmptyLine,
        ignoreEmptyLines: ignoreEmptyLines,
      );
}

extension ParseNdJsonString on Stream<String>? {
  /// {@macro parseNdjson}
  Stream<NdjsonLine> parseNdjson({
    bool ignoreEmptyLines = kDefaultIgnoreEmptyLines,
  }) =>
      base.parseNdjson(
        stream: this,
        ignoreEmptyLines: ignoreEmptyLines,
      );

  /// {@macro parseNdjsonWithConverter}
  Stream<T> parseNdjsonWithConverter<T>({
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
  }) =>
      base.parseNdjsonWithConverter<T>(
        stream: this,
        converter: converter,
        whenMap: whenMap,
        whenAny: whenAny,
        whenList: whenList,
        whenInt: whenInt,
        whenDouble: whenDouble,
        whenNum: whenNum,
        whenString: whenString,
        whenBool: whenBool,
        whenNull: whenNull,
        whenEmptyLine: whenEmptyLine,
        ignoreEmptyLines: ignoreEmptyLines,
      );
}
