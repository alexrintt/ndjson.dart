import 'dart:convert';
import 'dart:io';

import 'ndjson_test.dart';

final Directory dataDir = Directory('data');

String _readFileContents(String filename) => _file(filename).readAsStringSync();

File _file(String filename) =>
    File((dataDir.uri.pathSegments + <String>[filename]).join('/'));

Stream<List<int>> _encodeDataWithChunksOfRandomSize(String data) {
  return Stream<List<int>>.fromIterable(
    sliceRandomly(
      utf8.encode(data),
      random(1, data.length),
    ),
  );
}

Stream<List<int>> Function(String) getChunkedNdjsonDataGenerators() {
  final Map<String, Stream<List<int>> Function()> generators =
      <String, Stream<List<int>> Function()>{};

  for (final FileSystemEntity entity in dataDir.listSync()) {
    if (entity is File && entity.path.endsWith('ndjson')) {
      final File file = entity;

      final String filename = file.uri.pathSegments.last;

      generators[filename] =
          () => _encodeDataWithChunksOfRandomSize(_readFileContents(filename));
    }
  }

  return (String filename) => generators[filename]!();
}

int Function(String) getChunkedNdjsonDataLineCount() {
  final Map<String, int> lineCountOf = <String, int>{};

  for (final FileSystemEntity entity in dataDir.listSync()) {
    if (entity is File && entity.path.endsWith('ndjson')) {
      final File file = entity;

      final String filename = file.uri.pathSegments.last;

      lineCountOf[filename] = _file(filename).readAsLinesSync().length;
    }
  }

  return (String filename) => lineCountOf[filename]!;
}
