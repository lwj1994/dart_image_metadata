import 'package:collection/collection.dart';
import 'package:dart_image_metadata/dart_image_metadata.dart';
import 'package:dart_image_metadata/src/entity/block_entity.dart';

/// {@template image_size_getter.JpegDecoder}
///
/// [JpegDecoder] is a class for decoding JPEG image.
///
/// {@endtemplate}
class JpegDecoder extends BaseDecoder with SimpleTypeValidator {
  /// {@macro image_size_getter.JpegDecoder}
  const JpegDecoder();

  @override
  String get decoderName => 'jpeg';

  @override
  Future<bool> isValid(ImageInput input) async {
    try {
      final length = await input.length;

      // 确保文件足够长以包含 JPEG 头和尾
      if (length < 4) {
        return false;
      }

      // 获取文件头和尾
      final header = await input.getRange(0, _JpegInfo.start.length);

      // 检查头部和尾部标记是否符合 JPEG 文件格式
      final headerEquals = compareTwoList(header, _JpegInfo.start);
      if (!headerEquals) return false;

      final footer = await _findFooter(input, length);
      final footerEquals =
          footer.isNotEmpty && compareTwoList(footer, _JpegInfo.end);
      if (!footerEquals) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<int>> _findFooter(ImageInput input, int length) async {
    final int maxSearchLength = length ~/ 2; // 增加搜索范围
    final start = length - maxSearchLength;

    // 确保 start 不小于 0
    final adjustedStart = start < 0 ? 0 : start;

    final bytes = await input.getRange(adjustedStart, length);

    // 从后往前找到第一个 0xFF, 0xD9 标记
    for (int i = bytes.length - 2; i >= 0; i--) {
      if (bytes[i] == 0xFF && bytes[i + 1] == 0xD9) {
        return [0xFF, 0xD9];
      }
    }
    return []; // 未找到有效的尾部标记
  }

  @override
  Future<ImageMetadata> parse(ImageInput input) async {
    try {
      int start = 2;
      BlockEntity? block;
      int? orientation;

      while (true) {
        block = await _getBlockAsync(input, start);

        if (block == null) {
          return ImageMetadata(
              exception: Exception('block  is null, Invalid JPEG file'));
        }

        if (block.type == 0xE1) {
          final app1BlockData = await input.getRange(
            block.start,
            block.start + block.length,
          );
          final exifOrientation = _getOrientation(app1BlockData);
          if (exifOrientation != null) {
            orientation = exifOrientation;
          }
        }

        if (block.type == 0xD9 || _isStartOfFrameMarker(block.type)) {
          final widthList =
              await input.getRange(block.start + 7, block.start + 9);
          final heightList =
              await input.getRange(block.start + 5, block.start + 7);

          int width = convertRadix16ToInt(widthList);
          int height = convertRadix16ToInt(heightList);

          final rotate90Degree = [5, 6, 7, 8].contains(orientation);
          return ImageMetadata(
            width: rotate90Degree ? height : width,
            height: rotate90Degree ? width : height,
            orientation: orientation ?? 0,
            mimeType: "image/jpeg",
          );
        } else {
          start += block.length;
        }
      }
    } catch (e) {
      return ImageMetadata(exception: e);
    }
  }

  bool _isStartOfFrameMarker(int marker) {
    return [
      0xC0,
      0xC1,
      0xC2,
      0xC3,
      0xC5,
      0xC6,
      0xC7,
      0xC9,
      0xCA,
      0xCB,
      0xCD,
      0xCE,
      0xCF
    ].contains(marker);
  }

  Future<BlockEntity?> _getBlockAsync(ImageInput input, int blockStart) async {
    try {
      final blockInfoList = await input.getRange(blockStart, blockStart + 4);

      if (blockInfoList[0] != 0xFF) {
        return null;
      }

      final blockSizeList =
          await input.getRange(blockStart + 2, blockStart + 4);
      return _createBlock(blockSizeList, blockStart, blockInfoList);
    } catch (e) {
      return null;
    }
  }

  BlockEntity _createBlock(
      List<int> sizeList, int blockStart, List<int> blockInfoList) {
    final blockLength =
        convertRadix16ToInt(sizeList) + 2; // +2 for 0xFF and TYPE
    final typeInt = blockInfoList[1];
    return BlockEntity(typeInt, blockLength, blockStart);
  }

  @override
  SimpleFileHeaderAndFooter get simpleFileHeaderAndFooter => _JpegInfo();

  int? _getOrientation(List<int> app1BlockData) {
    if (app1BlockData.length < 14) {
      return null;
    }

    final exifIdentifier = app1BlockData.sublist(4, 10);
    final listEquality = ListEquality();

    if (!listEquality
        .equals(exifIdentifier, [0x45, 0x78, 0x69, 0x66, 0x00, 0x00])) {
      return null;
    }

    final littleEndian = app1BlockData[10] == 0x49;

    int getNumber(int start, int end) {
      final numberList = app1BlockData.sublist(start, end);
      return convertRadix16ToInt(numberList, reverse: littleEndian);
    }

    var idf0Start = 18;
    final tagEntryCount = getNumber(idf0Start, idf0Start + 2);
    var currentIndex = idf0Start + 2;

    for (var i = 0; i < tagEntryCount; i++) {
      final tagType = getNumber(currentIndex, currentIndex + 2);

      if (tagType == 0x0112) {
        return getNumber(currentIndex + 8, currentIndex + 10);
      }

      currentIndex += 0xC; // every tag length is 0xC bytes
    }

    return null;
  }
}

class _JpegInfo with SimpleFileHeaderAndFooter {
  static const start = [0xFF, 0xD8];
  static const end = [0xFF, 0xD9];

  @override
  List<int> get endBytes => end;

  @override
  List<int> get startBytes => start;
}
