# Lichess for Dart

[![Pub Version](https://img.shields.io/pub/v/ndjson)](https://pub.dev/packages/ndjson) [![Pub Version](https://img.shields.io/pub/points/ndjson)](https://pub.dev/packages/ndjson)

This is a library for interacting with [Lichess API](https://lichess.org/api). It works on all platforms and exposes a collection of data classes and a extendable client interface.

Notice: This is not an official Lichess project. It is maintained by volunteers.

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
final ndjsonStream = ...

// A new stream that will parse all chunks and emit events 
// for each new json object (not ndjson chunks).
final parsedNdjson = ndjsonStream.parseNdjsonBytesAsMap();

// If your ndjson stream is a stream of string, use [parseNdjsonStringAsMap] instead.
final parsedNdjson = ndjsonStream.parseNdjsonStringAsMap();

// If you wanna parse already:
final parsedNdjson = ndjsonStream.parseNdjsonString(converter: MyClass.fromJson);
```
