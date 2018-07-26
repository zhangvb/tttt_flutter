import 'dart:async';
import 'dart:convert' show json;

import 'package:http/http.dart' as HttpClient;

const baseUrl = 'https://238429054.tiantiantietu.xyz/weapp/feed';

class ImageContent {
  final int id;
  final String time;

  final String userId;
  final String userName;
  final String userAvatarUrl;

  final String imageUrl;
  final int imgWidth;
  final int imgHeight;

  int commentCount;
  int likeCount;
  int disCount;

  ImageContent.fromJson(Map<String, dynamic> map)
      : id = int.tryParse(map['id'] ?? ''),
        time = map['time'],
        userId = map['user_id'],
        userName = map['user_name'],
        userAvatarUrl = map['user_avatar'],
        imageUrl = map['img0'],
        imgWidth = int.tryParse(map['img0width'] ?? ''),
        imgHeight = int.tryParse(map['img0height'] ?? ''),
        commentCount = int.tryParse(map['comment_count'] ?? ''),
        likeCount = int.tryParse(map['like_count'] ?? ''),
        disCount = int.tryParse(map['dis_count'] ?? '');

  @override
  String toString() {
    return 'ImageContent{id: $id, time: $time, userId: $userId, userName: $userName, userAvatarUrl: $userAvatarUrl, imageUrl: $imageUrl, imgWidth: $imgWidth, imgHeight: $imgHeight, commentCount: $commentCount, likeCount: $likeCount, disCount: $disCount}';
  }
}

class ContentsManager {
  static ContentsManager _instance;

  List<ImageContent> _contents = [];
  List<ImageContent> get contents => List.from(_contents, growable: false);

  Future<bool> _curFetchingFuture;

  factory ContentsManager() => _instance ??= ContentsManager._internal();

  ContentsManager._internal();

  Future<bool> loadMore() {
    int startId = _contents.isEmpty ? 0 : _contents[_contents.length - 1].id;
    if (startId <= 0) {
      return refresh();
    }

    return _curFetchingFuture ??= _fetch(startId).then((fetchResult) {
      _curFetchingFuture = null;
      _contents.addAll(fetchResult);
      return true;
    }).catchError(() {
      return false;
    });
  }

  Future<bool> refresh() {
    return _curFetchingFuture ??= _fetch(0).then((fetchResult) {
      _curFetchingFuture = null;
      _contents.clear();
      _contents.addAll(fetchResult);
      return true;
    }).catchError(() {
      return false;
    });
  }

  bool isLoading() => _curFetchingFuture != null;

  bool hasContent() => _contents.isNotEmpty;

  ImageContent contentAt(int index) =>
      index >= _contents.length ? null : _contents[index];

  Future<List<ImageContent>> _fetch(int startId) async {
    try {
      List<ImageContent> result = [];

      String url =
          startId <= 0 ? baseUrl : (baseUrl + '?' + 'startId=$startId');

      HttpClient.Response response = await HttpClient.get(url);

      if (response.body != null) {
        result = (json.decode(response.body) as List)
            .map((e) => ImageContent.fromJson(e))
            .toList();

        print(result);

        result.removeWhere((value) => (value == null ||
            value.imageUrl == null ||
            value.imageUrl == '' ||
            value.id == null ||
            value.id <= 0));
      }
      print(result);
      return result;
    } catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
    }
  }
}
