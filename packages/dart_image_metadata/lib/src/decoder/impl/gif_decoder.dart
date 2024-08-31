import 'package:dart_image_metadata/dart_image_metadata.dart';

/// {@template image_size_getter.GifDecoder}
///
/// [GifDecoder] is a class for decoding gif image.
///
/// {@endtemplate}
class GifDecoder extends BaseDecoder with MutilFileHeaderAndFooterValidator {
  /// {@macro image_size_getter.GifDecoder}
  const GifDecoder();

  String get decoderName => 'gif';

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
  MutilFileHeaderAndFooter get headerAndFooter => _GifInfo();
}

class _GifInfo with MutilFileHeaderAndFooter {
  static const start89a = [
    0x47,
    0x49,
    0x46,
    0x38,
    0x37,
    0x61,
  ];
  static const start87a = [
    0x47,
    0x49,
    0x46,
    0x38,
    0x39,
    0x61,
  ];

  static const end = [0x3B];

  @override
  List<List<int>> get mutipleEndBytesList => [end];

  @override
  List<List<int>> get mutipleStartBytesList => [
        start87a,
        start89a,
      ];
}
