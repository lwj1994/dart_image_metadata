import 'dart:io';

/// {@template image_size_getter.FileUtils}
///
/// [FileUtils] is a class for file operations.
///
/// {@endtemplate}
class FileUtils {
  /// {@macro image_size_getter.FileUtils}
  FileUtils(this.file);

  /// The file.
  File file;

  /// {@template image_size_getter.FileUtils.getRangeSync}
  ///
  /// Get the range of bytes from [start] to [end].
  ///
  /// {@endtemplate}
  Future<List<int>> getRange(int start, int end) async {
    RandomAccessFile accessFile = await file.open();
    try {
      accessFile = await accessFile.setPosition(start);
      return (await accessFile.read(end - start)).toList();
    } catch (e) {
      return List<int>.empty();
    } finally {
      await accessFile.close();
    }
  }

  List<int> getRangeSync(int start, int end) {
    final accessFile = file.openSync();
    try {
      accessFile.setPositionSync(start);
      return accessFile.readSync(end - start).toList();
    } finally {
      accessFile.closeSync();
    }
  }
}
