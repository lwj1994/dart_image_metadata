
# dart_image_metadata
* fork from https://github.com/CaiJingLong/dart_image_size_getter

Read the metadata to get the image width、height、mimeType.
Support formats
* jpeg
* gif
* png
* webp
* heif
* bmp

## Usage

### Image of File

```dart
final meta = ImageMetadata.getWithFilePath('asset/IMG_20180908_080245.jpg');
```
