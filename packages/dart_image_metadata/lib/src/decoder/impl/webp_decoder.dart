import 'package:collection/collection.dart';
import 'package:dart_image_metadata/dart_image_metadata.dart';

/// {@template image_size_getter.WebpDecoder}
///
/// [WebpDecoder] is a class for decoding webp image.
///
/// {@endtemplate}
class WebpDecoder extends BaseDecoder {
  /// {@macro image_size_getter.WebpDecoder}
  const WebpDecoder();

  @override
  String get decoderName => 'webp';

  bool _isExtendedFormat(List<int> chunkHeader) {
    return ListEquality().equals(chunkHeader, "VP8X".codeUnits);
  }

  bool _isLosslessFormat(List<int> chunkHeader) {
    return ListEquality().equals(chunkHeader, "VP8L".codeUnits);
  }

  @override
  Future<ImageMetadata> parse(ImageInput input) async {
    try {
      final chunkHeader = await input.getRange(12, 16);
      int width = 0;
      int height = 0;
      if (_isExtendedFormat(chunkHeader)) {
        final widthList = await input.getRange(0x18, 0x1b);
        final heightList = await input.getRange(0x1b, 0x1d);
        width = convertRadix16ToInt(widthList, reverse: true) + 1;
        height = convertRadix16ToInt(heightList, reverse: true) + 1;
      } else if (_isLosslessFormat(chunkHeader)) {
        final sizeList = await input.getRange(0x15, 0x19);
        final bits = sizeList
            .map(
              (i) =>
                  i.toRadixString(2).split('').reversed.join().padRight(8, '0'),
            )
            .join()
            .split('');
        width =
            (int.tryParse(bits.sublist(0, 14).reversed.join(), radix: 2) ?? 0) +
                1;
        height =
            (int.tryParse(bits.sublist(14, 28).reversed.join(), radix: 2) ??
                    0) +
                1;
      } else {
        final widthList = await input.getRange(0x1a, 0x1c);
        final heightList = await input.getRange(0x1c, 0x1e);
        width = convertRadix16ToInt(widthList, reverse: true);
        height = convertRadix16ToInt(heightList, reverse: true);
      }

      return ImageMetadata(
        width: width,
        height: height,
        mimeType: "image/webp",
      );
    } catch (e) {
      return ImageMetadata(exception: e);
    }
  }

  @override
  Future<bool> isValid(ImageInput input) async {
    try {
      final sizeStart = await input.getRange(0, 4);
      final sizeEnd = await input.getRange(8, 12);

      const eq = ListEquality();

      if (eq.equals(sizeStart, _WebpHeaders.fileSizeStart) &&
          eq.equals(sizeEnd, _WebpHeaders.fileSizeEnd)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class _WebpHeaders with SimpleFileHeaderAndFooter {
  static const fileSizeStart = [
    0x52,
    0x49,
    0x46,
    0x46,
  ];

  static const fileSizeEnd = [
    0x57,
    0x45,
    0x42,
    0x50,
  ];

  @override
  List<int> get endBytes => fileSizeEnd;

  @override
  List<int> get startBytes => fileSizeStart;
}
