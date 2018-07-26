import 'dart:async';

class ImageContent {
  final imageUrl;

  const ImageContent(this.imageUrl);
}

class ContentsManager {
  static ContentsManager _instance;

  factory ContentsManager() => _instance ??= ContentsManager();

  List<ImageContent> _contents = [];
  List<ImageContent> get contents => List.from(_contents, growable: false);

  Future<List<ImageContent>> loadMore() async {
    return null;
  }

  Future<List<ImageContent>> refresh() async {
    return null;
  }

  bool hasContent() => _contents.isNotEmpty;

  ImageContent contentAt(int index) =>
      index >= _contents.length ? null : _contents[index];
}
