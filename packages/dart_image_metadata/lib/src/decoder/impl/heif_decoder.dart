import 'dart:typed_data';

import 'package:bmff/bmff.dart';
import 'package:collection/collection.dart';
import 'package:dart_image_metadata/src/decoder/decoder.dart';
import 'package:dart_image_metadata/src/metadata.dart';

class HeifDecoder extends BaseDecoder {
  HeifDecoder({this.fullTypeBox = _defaultFullBoxTypes});

  final List<String> fullTypeBox;

  @override
  String get decoderName => 'heif';

  @override
  Future<ImageMetadata> parse(ImageInput input) async {
    try {
      final context = AsyncBmffContext.common(
        () => input.length,
        (start, end) => input.getRange(start, end),
        fullBoxTypes: fullTypeBox,
      );

      final bmff = await Bmff.asyncContext(context);
      final meta =
          bmff.childBoxes.firstWhereOrNull((box) => box.type == 'meta');
      if (meta == null) {
        throw Exception('meta box not found');
      }

      final iprp =
          meta.childBoxes.firstWhereOrNull((box) => box.type == 'iprp');
      if (iprp == null) {
        throw Exception('iprp box not found');
      }

      final ipco =
          iprp.childBoxes.firstWhereOrNull((box) => box.type == 'ipco');
      if (ipco != null) {
        // 检查是否存在 ispe box
        final ispeBox =
            ipco.childBoxes.firstWhereOrNull((box) => box.type == 'ispe');

        if (ispeBox != null) {
          final buffer = await ispeBox.getByteBuffer();
          final width = buffer.getUint32(0, Endian.big);
          final height = buffer.getUint32(1, Endian.big);
          return ImageMetadata(
            width: width,
            height: height,
            mimeType: "image/heif",
          );
        }
      }
      throw Exception('ispe box not found');
    } catch (e) {
      return ImageMetadata(exception: e);
    }
  }

  @override
  Future<bool> isValid(ImageInput input) async {
    try {
      final lengthBytes = await input.getRange(0, 4);
      final length = lengthBytes.toBigEndian();
      final typeBoxBytes = await input.getRange(0, length);
      final bmff = Bmff.memory(typeBoxBytes);
      return _checkHeic(bmff);
    } catch (e) {
      return false;
    }
  }

  bool _checkHeic(Bmff bmff) {
    final typeBox = bmff.typeBox;
    final compatibleBrands = typeBox.compatibleBrands;
    return compatibleBrands.contains('heic') ||
        compatibleBrands.contains('heif');
  }
}

class BmffImageContext extends BmffContext {
  final ImageInput input;

  BmffImageContext(
    this.input, {
    List<String> fullBoxTypes = _defaultFullBoxTypes,
  }) : super(fullBoxTypes: fullBoxTypes);

  @override
  void close() {}

  @override
  List<int> getRangeData(int start, int end) {
    return input.getRangeSync(start, end);
  }

  @override
  int get length => input.lengthSync;
}

const List<String> _defaultFullBoxTypes = [
  // 'ftyp', // 文件类型 box
  'meta', // 元数据 box
  'ispe', // 图像空间信息 box
];
