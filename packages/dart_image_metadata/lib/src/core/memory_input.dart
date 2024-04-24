import 'dart:typed_data';

import 'package:dart_image_metadata/src/core/input.dart';

class MemoryInput extends ImageInput {
  final Uint8List bytes;

  const MemoryInput(this.bytes);

  factory MemoryInput.byteBuffer(ByteBuffer buffer) {
    return MemoryInput(buffer.asUint8List());
  }

  @override
  Future<List<int>> getRange(int start, int end) {
    return Future.value(getRangeSync(start, end));
  }

  @override
  Future<int> get length => Future.value(bytes.length);

  @override
  Future<bool> exists() {
    return Future.value(bytes.isNotEmpty);
  }

  @override
  List<int> getRangeSync(int start, int end) {
    return bytes.sublist(start, end);
  }

  @override
  int get lengthSync => bytes.length;
}
