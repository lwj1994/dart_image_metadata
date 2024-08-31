import 'dart:typed_data';

import 'package:bmff/bmff.dart';
import 'package:dart_image_metadata/dart_image_metadata.dart';

class HeifDecoder extends BaseDecoder {
  HeifDecoder({this.fullTypeBox = defaultFullBoxTypes});

  final List<String> fullTypeBox;

  @override
  String get decoderName => 'heif';

  @override
  Future<ImageMetadata> parse(ImageInput input) async {
    try {
      final context = AsyncBmffContext.common(
        () {
          return input.length;
        },
        (start, end) => input.getRange(start, end),
        fullBoxTypes: fullTypeBox,
      );

      final bmff = await Bmff.asyncContext(context);
      // final iprp = bmff['meta']['iprp'];
      // final ispe = await iprp.updateForceFullBox(false).then((value) async {
      //   final ipco = iprp['ipco'];
      //   await ipco.init();
      //   return ipco;
      // }).then((value) => value['ispe']);

      final ispe = bmff['meta']['iprp']['ipco']['ispe'];

      final buffer = await ispe.getByteBuffer();

      final width = buffer.getUint32(0, Endian.big);
      final height = buffer.getUint32(1, Endian.big);

      return ImageMetadata(
        width: width,
        height: height,
        mimeType: "image/heif",
      );
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
    List<String> fullBoxTypes = defaultFullBoxTypes,
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

const List<String> defaultFullBoxTypes = [
  'meta',
  // 'hdlr',
  // 'pitm',
  // 'iloc',
  // 'iinf',
  // 'infe',
  // 'iref',
  'ispe',
];
