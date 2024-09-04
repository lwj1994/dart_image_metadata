import 'package:dart_image_metadata/dart_image_metadata.dart';
import 'package:test/test.dart';

void main() {
  group('Test decoders', () {
    test('Test yaml decoder', () async {
      await testFile("../../example/asset/analysis_options.yaml");
    });

    test('Test mp3 decoder', () async {
      await testFile("../../example/asset/test.mp3");
    });

    test('Test gif decoder', () async {
      await testFile("../../example/asset/3.gif");
    });

    test('Test jpeg decoder', () async {
      await testFile("../../example/asset/issue27/issue27-1.jpg");
      await testFile("../../example/asset/IMG_20180908_080245.jpg");
      await testFile("../../example/asset/IMG_20240905_104953.jpg");
      await testFile("../../example/asset/motion.jpeg");
    });

    test('Test png decoder', () async {
      await testFile("../../example/asset/img.png");
    });
    //
    test('Test webp decoder', () async {
      await testFile("../../example/asset/webp.webp");
    });

    test('Test heif decoder', () async {
      await testFile("../../example/asset/apple.heic");
    });
  });
}

Future<void> testFile(String path) async {
  try {
    final res = await ImageMetadata.getWithFilePath(path);
    print("\n$path :" + res.toString());
  } catch (e) {
    //
    print("\n$path " + e.toString());
  }
}
