import 'dart:io';

import 'package:ndjson/ndjson.dart';

final File ndjsonValidSample = File('./data/ndjson-valid-sample-00.ndjson');
Stream<List<int>> get ndjsonSource => ndjsonValidSample.openRead();

void main() async {
  await _usingFunction();
  await _usingExtension();
}

Future<void> _usingFunction() async {
  final Stream<NdjsonLine> ndjson =
      parseNdjson(byteStream: ndjsonSource, ignoreEmptyLines: true);

  print(await ndjson.toList());
}

Future<void> _usingExtension() async {
  final Stream<NdjsonLine> ndjson = ndjsonSource.parseNdjson();

  print(await ndjson.toList());
}
