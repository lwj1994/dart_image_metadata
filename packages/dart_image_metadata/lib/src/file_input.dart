import 'dart:io';

import 'package:dart_image_metadata/src/core/input.dart';
import 'package:dart_image_metadata/src/utils/file_utils.dart';

///
/// {@template image_size_getter.file_input}
///
/// [ImageInput] using file as input source.
///
/// {@endtemplate}
///
class FileInput extends ImageInput {
  /// {@macro image_size_getter.file_input}
  const FileInput(this.file);

  final File file;

  @override
  Future<List<int>> getRange(int start, int end) {
    final utils = FileUtils(file);
    return utils.getRange(start, end);
  }

  @override
  Future<int> get length => file.length();

  @override
  Future<bool> exists() {
    return file.exists();
  }

  @override
  List<int> getRangeSync(int start, int end) {
    final utils = FileUtils(file);
    return utils.getRangeSync(start, end);
  }

  @override
  int get lengthSync => file.lengthSync();
}
