import 'package:dart_image_metadata/dart_image_metadata.dart';

/// {@template image_size_getter.GifDecoder}
///
/// [GifDecoder] is a class for decoding GIF image.
///
/// {@endtemplate}
class GifDecoder extends BaseDecoder with MultiFileHeaderAndFooterValidator {
  /// {@macro image_size_getter.GifDecoder}
  const GifDecoder();

  @override
  String get decoderName => 'gif';

  @override
  Future<bool> isValid(ImageInput input) async {
    try {
      final length = await input.length;

      for (final header in headerAndFooter.multipleStartBytesList) {
        for (final footer in headerAndFooter.multipleEndBytesList) {
          final fileHeader = await input.getRange(0, header.length);
          final fileFooter =
              await input.getRange(length - footer.length, length);

          final headerEquals = compareTwoList(header, fileHeader);
          final footerEquals = compareTwoList(footer, fileFooter);

          if (headerEquals && footerEquals) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ImageMetadata> parse(ImageInput input) async {
    try {
      final widthList = await input.getRange(6, 8);
      final heightList = await input.getRange(8, 10);
      final width = convertRadix16ToInt(widthList, reverse: true);
      final height = convertRadix16ToInt(heightList, reverse: true);

      return ImageMetadata(width: width, height: height, mimeType: "image/gif");
    } catch (e) {
      return ImageMetadata(exception: e);
    }
  }

  @override
  MultiFileHeaderAndFooter get headerAndFooter => _GifInfo();
}

class _GifInfo with MultiFileHeaderAndFooter {
  static const start89a = [
    0x47, 0x49, 0x46, 0x38, 0x37, 0x61, // GIF87a
  ];
  static const start87a = [
    0x47, 0x49, 0x46, 0x38, 0x39, 0x61, // GIF89a
  ];

  static const end = [0x3B]; // GIF file terminator

  @override
  List<List<int>> get multipleEndBytesList => [end];

  @override
  List<List<int>> get multipleStartBytesList => [start87a, start89a];
}
