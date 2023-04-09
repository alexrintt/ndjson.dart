# ndjson parser for Dart

[![Pub Version](https://img.shields.io/pub/v/ndjson)](https://pub.dev/packages/ndjson) [![Pub Version](https://img.shields.io/pub/points/ndjson)](https://pub.dev/packages/ndjson)

Tiny and simple ndjson parser library for Dart. No external dependencies.

## Installation

```yaml
dependencies:
  ndjson: ^<latest-version>
```

Import:

```dart
import 'package:ndjson/ndjson.dart';
```

## Usage

The usage is pretty straightforward:

```dart
import 'package:ndjson/ndjson.dart';

// Your ndjson stream.
final Stream<NdjsonLine|List<int>> ndjsonStream = ...

// A new stream that will parse all chunks and emit events 
// for each new json object (not ndjson chunks).
final Stream<NdjsonLine> parsedNdjson = ndjsonStream.parseNdjson();

// Using converter functions:
final Stream<Dummy> ndjson = ndjsonSource.parseNdjsonWithConverter<Dummy>(
  whenMap: Dummy.fromJson,
);
```

---

Supported ndjson types are:

- `Stream<List<int>>`.
- `Stream<Uint8List>`.
- `Stream<String>`.

---

Any list-like ndjson source can be converted to `Stream` using:

```dart
Stream.fromIterable(ndjsonList);
```

**You must be aware that using ndjson as list is the same as a regular json (you lose all ndjson performance benefits).**
