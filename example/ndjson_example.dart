import 'dart:io';

import 'package:ndjson/ndjson.dart';

final File ndjsonValidSample = File('./data/ndjson-valid-sample.ndjson');
final Stream<List<int>> ndjsonSource = ndjsonValidSample.openRead();

void main() async {
  _usingFunction();
  _usingExtension();
}

Future<void> _usingFunction() async {
  final Stream<Map<String, dynamic>> ndjson =
      parseNdjsonBytesAsMap(ndjsonSource);

  print(await ndjson.toList());
}

Future<void> _usingExtension() async {
  final Stream<Map<String, dynamic>> ndjson =
      ndjsonSource.parseNdjsonBytesAsMap();

  print(await ndjson.toList());
}
