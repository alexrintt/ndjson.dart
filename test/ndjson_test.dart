import 'dart:math';

import 'package:ndjson/ndjson.dart';
import 'package:test/test.dart';

import 'ndjson_samples.dart';

int random(int lower, int upper) {
  if (lower == upper) return upper;

  lower = min(lower, upper);
  upper = max(lower, upper);

  return Random().nextInt(upper - lower) + lower;
}

List<List<T>> sliceRandomly<T>(List<T> source, int baseSize) {
  final List<List<T>> sliced = <List<T>>[];

  while (source.isNotEmpty) {
    final int size = min(source.length, random(1, baseSize));

    sliced.add(source.sublist(0, size));

    source = source.sublist(size);
  }

  return sliced;
}

void main() {
  Stream<List<int>> Function(String) generateSampleData =
      getChunkedNdjsonDataGenerators();
  int Function(String) getSampleDataLineCount = getChunkedNdjsonDataLineCount();

  group('Helper functions', () {
    test('Helper function [sliceRandomly]', () {
      final List<int> source = <int>[for (int i = 0; i < 1000; i++) i];

      for (int i = 0; i < 10; i++) {
        // Slice randomly.
        final List<List<int>> sliced = sliceRandomly(source, 10);
        final List<List<int>> slicedAgain = sliceRandomly(source, 10);

        final List<int> merged = sliced.reduce(
          (List<int> value, List<int> element) => <int>[...value, ...element],
        );

        expect(merged, source);

        if (sliced.length != slicedAgain.length) {
          // Already different, pass item check.
          continue;
        }

        for (int j = 0; j < sliced.length; j++) {
          if (sliced[j].length != slicedAgain[j].length) {
            // Different, passed.
            break;
          } else {
            if (j == sliced.length - 1) {
              // Last item, and it's not different, so it failed to generate
              // two random sequences at least a bit different.
              fail('j: $j, i: $i, sliced: $sliced.');
            }
          }
        }
      }
    });
  });

  group('Parse ndjson ', () {
    test('[primitive-with-empty-lines.ndjson]', () async {
      for (int i = 0; i < 1e4; i++) {
        final Stream<List<int>> ndjsonSource =
            generateSampleData('primitive-with-empty-lines.ndjson');

        final Stream<NdjsonLine> sourceNdjsonIncluingEmptyLines =
            parseNdjson(byteStream: ndjsonSource, ignoreEmptyLines: false);

        final Stream<NdjsonLine> sourceNdjsonIgnoringEmptyLines =
            parseNdjson(byteStream: ndjsonSource, ignoreEmptyLines: true);

        final List<NdjsonLine> ndjsonIncluingEmptyLines =
            await sourceNdjsonIncluingEmptyLines.toList();

        final List<NdjsonLine> ndjsonIgnoringEmptyLines =
            await sourceNdjsonIgnoringEmptyLines.toList();

        expect(
          ndjsonIncluingEmptyLines.length,
          equals(getSampleDataLineCount('primitive-with-empty-lines.ndjson')),
        );
        expect(
          ndjsonIgnoringEmptyLines.length,
          isNot(equals(
              getSampleDataLineCount('primitive-with-empty-lines.ndjson'))),
        );
        expect(
          ndjsonIgnoringEmptyLines.every((NdjsonLine line) => line.isPrimitive),
          isTrue,
        );
      }
    });
    test('[object.ndjson]', () async {
      for (int i = 0; i < 1e3; i++) {
        final Stream<List<int>> ndjsonSource =
            generateSampleData('object.ndjson');

        final Stream<NdjsonLine> sourceNdjsonIgnoringEmptyLines =
            parseNdjson(byteStream: ndjsonSource, ignoreEmptyLines: true);

        final List<NdjsonLine> ndjsonIgnoringEmptyLines =
            await sourceNdjsonIgnoringEmptyLines.toList();

        expect(
          ndjsonIgnoringEmptyLines.length,
          equals(getSampleDataLineCount('object.ndjson')),
        );
        expect(
          ndjsonIgnoringEmptyLines.every((NdjsonLine line) => line.isMap),
          isTrue,
        );
      }
    });
    test('[primitive.ndjson]', () async {
      for (int i = 0; i < 1e3; i++) {
        final Stream<List<int>> ndjsonSource =
            generateSampleData('primitive.ndjson');

        final Stream<NdjsonLine> sourceNdjsonIgnoringEmptyLines =
            parseNdjson(byteStream: ndjsonSource, ignoreEmptyLines: true);

        final List<NdjsonLine> ndjsonIgnoringEmptyLines =
            await sourceNdjsonIgnoringEmptyLines.toList();

        expect(
          ndjsonIgnoringEmptyLines.length,
          equals(getSampleDataLineCount('primitive.ndjson')),
        );
        expect(
          ndjsonIgnoringEmptyLines.every((NdjsonLine line) => line.isPrimitive),
          isTrue,
        );
      }
    });
    test('[invalid-object.ndjson]', () async {
      for (int i = 0; i < 1e3; i++) {
        final Stream<List<int>> ndjsonSource =
            generateSampleData('invalid-object.ndjson');

        final Stream<NdjsonLine> invalidSourceNdjson =
            parseNdjson(byteStream: ndjsonSource, ignoreEmptyLines: true);

        expect(
          (await invalidSourceNdjson.toList())
              .any((NdjsonLine line) => line.isInvalid),
          isTrue,
        );
      }
    });
    test('[array.ndjson]', () async {
      for (int i = 0; i < 1e3; i++) {
        final Stream<List<int>> ndjsonSource =
            generateSampleData('array.ndjson');

        final Stream<NdjsonLine> sourceNdjson =
            parseNdjson(byteStream: ndjsonSource, ignoreEmptyLines: true);

        expect(
          (await sourceNdjson.toList()).every((NdjsonLine line) => line.isList),
          isTrue,
        );
      }
    });
    test('Equality between identical ndjson lines must result true', () async {
      for (int i = 0; i < 1e3; i++) {
        final Stream<List<int>> ndjsonSource =
            generateSampleData('object.ndjson');

        final List<NdjsonLine> result1 =
            await parseNdjson(byteStream: ndjsonSource, ignoreEmptyLines: true)
                .toList();

        final List<NdjsonLine> result2 =
            await parseNdjson(byteStream: ndjsonSource, ignoreEmptyLines: true)
                .toList();

        expect(result1, equals(result2));
        expect(
          result1 + <NdjsonLine>[NdjsonLine('a')],
          isNot(equals(result2 + <NdjsonLine>[NdjsonLine('b')])),
        );
        expect(
          result1 + <NdjsonLine>[NdjsonLine('a')],
          equals(result2 + <NdjsonLine>[NdjsonLine('a')]),
        );

        final NdjsonLine sameInstance = NdjsonLine('a');

        expect(
          result1 + <NdjsonLine>[sameInstance],
          equals(result2 + <NdjsonLine>[sameInstance]),
        );
      }
    });
    test('Use [converter] of primitive data types [primitive.ndjson]',
        () async {
      for (int i = 0; i < 1e3; i++) {
        final Stream<List<int>> ndjsonSource =
            generateSampleData('primitive.ndjson');

        final List<String> ndjsonPrimiveValues =
            await parseNdjsonWithConverter<String>(
          byteStream: ndjsonSource,
          ignoreEmptyLines: true,
          whenInt: (int value) => 'Integer: $value',
          whenString: (String value) => 'String: $value',
          whenDouble: (double value) => 'Double: $value',
          whenBool: (bool value) => 'Boolean: $value',
          whenNull: () => 'Null!',
          whenEmptyLine: () => 'Empty line!',
        ).toList();

        expect(
          ndjsonPrimiveValues.length,
          equals(getSampleDataLineCount('primitive.ndjson')),
        );
      }
    });
    test('Use [converter] to parse complex data types [object.ndjson]',
        () async {
      for (int i = 0; i < 1e3; i++) {
        final Stream<List<int>> ndjsonSource =
            generateSampleData('object.ndjson');

        final List<Dummy> ndjsonPrimiveValues =
            await parseNdjsonWithConverter<Dummy>(
          byteStream: ndjsonSource,
          ignoreEmptyLines: true,
          whenMap: Dummy.fromJson,
        ).toList();

        expect(
          ndjsonPrimiveValues.length,
          equals(getSampleDataLineCount('object.ndjson')),
        );
      }
    });
  });
}

class Dummy {
  const Dummy(this.id, this.name);

  factory Dummy.fromJson(Map<String, dynamic> map) {
    return Dummy(map['id'] as int, map['name'] as String);
  }

  final int id;
  final String name;
}
