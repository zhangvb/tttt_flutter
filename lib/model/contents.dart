import 'dart:async';
import 'dart:convert' show json;

import 'package:http/http.dart' as HttpClient;

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
        imageUrl =
            'http://h.hiphotos.baidu.com/image/h%3D300/sign=ff6ed7cfa718972bbc3a06cad6cc7b9d/267f9e2f07082838304837cfb499a9014d08f1a0.jpg', //map['img0'],
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
  static const _baseUrl = 'https://238429054.tiantiantietu.xyz/weapp/feed';
  static ContentsManager _instance;

  List<ImageContent> _contents = [];
  List<ImageContent> get contents => List.from(_contents, growable: false);

  Future<bool> _curFetchingFuture;

  factory ContentsManager() => _instance ??= ContentsManager._internal();

  ContentsManager._internal();

  Future<bool> loadMore() {
    print('load more');
    int startId = _contents.isEmpty ? 0 : _contents[_contents.length - 1].id;
    if (startId <= 0) {
      return refresh();
    }

    return _curFetchingFuture ??= _fetch(startId).then((fetchResult) {
      print('afeter loadmore');
      _curFetchingFuture = null;
      _contents.addAll(fetchResult);
      return true;
    }).catchError(() {
      print('afeter error');
      return false;
    });
  }

  Future<bool> refresh() {
    print('refresh');
    return _curFetchingFuture ??= _fetch(0).then((fetchResult) {
      print('afeter refresh');
      _curFetchingFuture = null;
      _contents.clear();
      _contents.addAll(fetchResult);
      return true;
    }).catchError(() {
      print('afeter refresh error');
      return false;
    });
  }

  bool isLoading() => _curFetchingFuture != null;

  bool hasContent() => _contents.isNotEmpty;

  int size() => _contents.length;

  ImageContent contentAt(int index) =>
      index >= _contents.length ? null : _contents[index];

  Future<List<ImageContent>> _fetch(int startId) async {
    List<ImageContent> result = [];
    try {
      print('_fetch');
      String url =
          startId <= 0 ? _baseUrl : (_baseUrl + '?' + 'startId=$startId');
      Future.delayed(const Duration(milliseconds: 3));
      HttpClient.Response response = await HttpClient.get(url);

      if (response.body != null) {
        result = (json.decode(response.body) as List)
            .map((e) => ImageContent.fromJson(e))
            .toList();

        result.removeWhere((value) => (value == null ||
            value.imageUrl == null ||
            value.imageUrl == '' ||
            value.id == null ||
            value.id <= 0));
      }
      print(result);
    } catch (e, s) {
      print('Exception details:\n $e');
      print('Stack trace:\n $s');
    }
    return result;
  }
}
