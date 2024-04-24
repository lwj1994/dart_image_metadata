import 'package:dart_image_metadata/dart_image_metadata.dart';

/// {@template image_ImageMetaData_getter.BmpDecoder}
///
/// [BmpDecoder] is a class for decoding BMP file.
///
/// {@endtemplate}
class BmpDecoder extends BaseDecoder {
  const BmpDecoder();

  @override
  String get decoderName => 'bmp';

  @override
  Future<ImageMetadata> parse(ImageInput input) async {
    final widthList = await input.getRange(0x12, 0x16);
    final heightList = await input.getRange(0x16, 0x1a);

    final width = convertRadix16ToInt(widthList, reverse: true);
    final height = convertRadix16ToInt(heightList, reverse: true);
    return ImageMetadata(width: width, height: height, mimeType: "image/bmp");
  }

  @override
  Future<bool> isValid(ImageInput input) async {
    final list = await input.getRange(0, 2);
    return _isBmp(list);
  }

  bool _isBmp(List<int> startList) {
    return startList[0] == 66 && startList[1] == 77;
  }
}
