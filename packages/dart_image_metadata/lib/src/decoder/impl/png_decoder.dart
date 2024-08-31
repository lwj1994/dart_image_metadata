import 'package:dart_image_metadata/dart_image_metadata.dart';

/// {@template image_size_getter.PngDecoder}
///
/// [PngDecoder] is a class for decoding PNG image.
///
/// {@endtemplate}
class PngDecoder extends BaseDecoder with SimpleTypeValidator {
  /// {@macro image_size_getter.PngDecoder}
  const PngDecoder();

  @override
  String get decoderName => 'png';

  @override
  Future<ImageMetadata> parse(ImageInput input) async {
    try {
      final widthList = await input.getRange(0x10, 0x14);
      final heightList = await input.getRange(0x14, 0x18);
      final width = convertRadix16ToInt(widthList);
      final height = convertRadix16ToInt(heightList);
      return ImageMetadata(
        width: width,
        height: height,
        mimeType: "image/png",
      );
    } catch (e) {
      return ImageMetadata(exception: e);
    }
  }

  @override
  SimpleFileHeaderAndFooter get simpleFileHeaderAndFooter => _PngHeaders();
}

class _PngHeaders with SimpleFileHeaderAndFooter {
  static const sig = [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
  ];

  static const iend = [
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82
  ];

  @override
  List<int> get endBytes => iend;

  @override
  List<int> get startBytes => sig;
}
