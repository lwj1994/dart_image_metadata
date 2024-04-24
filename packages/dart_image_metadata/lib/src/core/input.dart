///
/// {@template image_size_getter.image_input}
///
/// Provide a data source for [ImageSizeGetter] to get image size.
///
/// {@endtemplate}
///

/// {@template image_size_getter.HaveResourceImageInput}
///
/// There are resources in these classes that need to be released.
///
/// This class is a wrapper class that will automatically release resources after use.
/// Once released, many resources are no longer effective.
///
/// {@endtemplate}
class HaveResourceImageInput extends ImageInput {
  /// {@macro image_size_getter.HaveResourceImageInput}
  ///
  /// [input] is the input data of [ImageInput].
  /// [onRelease] is the function to release the resources.
  ///
  const HaveResourceImageInput({
    required this.innerInput,
    this.onRelease,
  });

  /// The input data of [ImageInput].
  final ImageInput innerInput;

  /// The function to release the resources.
  final Future<void> Function()? onRelease;

  /// Release the resources.
  Future<void> release() async {
    await onRelease?.call();
  }

  @override
  Future<bool> exists() {
    return innerInput.exists();
  }

  @override
  Future<List<int>> getRange(int start, int end) {
    return innerInput.getRange(start, end);
  }

  @override
  Future<int> get length => innerInput.length;

  @override
  Future<HaveResourceImageInput> delegateInput() {
    return innerInput.delegateInput();
  }

  @override
  List<int> getRangeSync(int start, int end) {
    return innerInput.getRangeSync(start, end);
  }

  @override
  int get lengthSync => innerInput.lengthSync;
}

/// {@template image_size_getter.AsyncImageInput}
///
/// {@macro image_size_getter.image_input}
///
/// Unlike [ImageInput], the methods of this class are asynchronous.
///
/// {@endtemplate}
abstract class ImageInput {
  /// {@macro image_size_getter.image_input}
  ///
  /// {@macro image_size_getter.AsyncImageInput}
  const ImageInput();

  /// Whether partial loading is supported.
  ///
  /// Many asynchronous sources do not allow partial reading.
  bool supportRangeLoad() {
    return true;
  }

  /// When asynchronous reading is not supported,
  /// an input for real reading will be cached in memory(web) or file(dart.io).
  Future<HaveResourceImageInput> delegateInput() {
    return Future.value(HaveResourceImageInput(innerInput: this));
  }

  /// Get a range of bytes from the input data.
  Future<int> get length;

  int get lengthSync;

  /// Get a range of bytes from the input data.
  ///
  /// [start] and [end] are the start and end index of the range.
  ///
  /// Such as: [start] = 0, [end] = 2, then the result is [0, 1].
  Future<List<int>> getRange(int start, int end);

  List<int> getRangeSync(int start, int end);

  /// Check if the input data exists.
  Future<bool> exists();
}
