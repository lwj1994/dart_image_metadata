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
  Future<bool> isValid(ImageInput input) async {
    try {
      // 获取文件长度
      final length = await input.length;

      // 检查文件长度是否足够
      if (length < 24) {
        return false; // 不足以包含 PNG 头和基本结构
      }

      // 获取文件头部和尾部
      final header = await input.getRange(0, _PngHeaders.sig.length);
      final ihdrChunkType = await input.getRange(
          _PngHeaders.sig.length + 4, _PngHeaders.sig.length + 8);
      final footer =
          await input.getRange(length - _PngHeaders.iend.length, length);

      // 检查头部和尾部标记是否符合 PNG 文件格式
      final headerEquals = compareTwoList(header, _PngHeaders.sig);
      final footerEquals = compareTwoList(footer, _PngHeaders.iend);

      // 进一步检查第一个块是否为 IHDR 块
      final isIHDRChunk = compareTwoList(ihdrChunkType, _PngHeaders.ihdr);

      return headerEquals && footerEquals && isIHDRChunk;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ImageMetadata> parse(ImageInput input) async {
    try {
      // 提取宽度和高度信息
      final widthList = await input.getRange(0x10, 0x14);
      final heightList = await input.getRange(0x14, 0x18);

      if (widthList.length != 4 || heightList.length != 4) {
        throw Exception('Invalid PNG dimensions');
      }

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
    0x89, 0x50, 0x4E, 0x47, // PNG Signature
    0x0D, 0x0A, 0x1A, 0x0A, // Newline, EOF, etc.
  ];

  static const ihdr = [
    0x49, 0x48, 0x44, 0x52, // IHDR Chunk
  ];

  static const iend = [
    0x00, 0x00, 0x00, 0x00, // Chunk length (may vary)
    0x49, 0x45, 0x4E, 0x44, // IEND
    0xAE, 0x42, 0x60, 0x82 // CRC checksum
  ];

  @override
  List<int> get endBytes => iend;

  @override
  List<int> get startBytes => sig;
}
