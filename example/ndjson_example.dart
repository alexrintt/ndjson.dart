import 'dart:io';

import 'package:ndjson/ndjson.dart';

final File ndjsonValidSample = File('./data/object.ndjson');
Stream<List<int>> get ndjsonSource => ndjsonValidSample.openRead();

void main() async {
  await _usingFunction();
  await _usingExtension();
  await _usingExtensionWithConverter();
}

Future<void> _usingFunction() async {
  final Stream<NdjsonLine> ndjson = parseNdjson(byteStream: ndjsonSource);

  print(await ndjson.toList());
}

Future<void> _usingExtension() async {
  final Stream<NdjsonLine> ndjson = ndjsonSource.parseNdjson();

  print(await ndjson.toList());
}

Future<void> _usingExtensionWithConverter() async {
  final Stream<Dummy> ndjson = ndjsonSource.parseNdjsonWithConverter<Dummy>(
    whenMap: Dummy.fromJson,
  );

  print(await ndjson.toList());
}

class Dummy {
  const Dummy(this.id, this.name);

  factory Dummy.fromJson(Map<String, dynamic> map) {
    return Dummy(map['id'] as int, map['name'] as String);
  }

  final int id;
  final String name;
}
