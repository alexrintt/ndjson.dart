import 'dart:io';

import 'package:ndjson/ndjson.dart';
import 'package:test/test.dart';

void main() {
  group('Parse njdson', () {
    test('Chunked', () async {
      final File ndjsonSample = File('./data/ndjson-valid-sample-00.ndjson');

      final Stream<List<int>> ndjsonSource = ndjsonSample.openRead();

      final Stream<Map<String, dynamic>> ndjson =
          parseNdjsonBytesAsMap(ndjsonSource);

      expect(await ndjson.length, ndjsonSample.readAsLinesSync().length);
    });
    test('Chunked with last line invalid', () async {
      final File ndjsonSample = File('./data/ndjson-invalid-sample-00.ndjson');

      final Stream<List<int>> ndjsonSource = ndjsonSample.openRead();

      final Stream<Map<String, dynamic>> ndjson =
          parseNdjsonBytesAsMap(ndjsonSource);

      // -1 because the last line is invalid
      expect(await ndjson.length, ndjsonSample.readAsLinesSync().length - 1);
    });
  });
}
