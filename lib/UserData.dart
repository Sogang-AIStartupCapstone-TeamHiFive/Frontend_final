import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class Friend {
  final int user_id;
  final String nickname;
  final String name;
  final String sex;
  final int age;
  final String profile_image_url;
  final String bio;
  final bool friend_ship;
  final String hair_style;
  final String glasses;
  final String body_type;

  Friend({
    required this.user_id,
    required this.nickname,
    required this.name,
    required this.sex,
    required this.age,
    required this.profile_image_url,
    required this.bio,
    required this.friend_ship,
    required this.hair_style,
    required this.glasses,
    required this.body_type,
  });
}

class Post {
  final List<String> images_url;
  final String original;
  final String title;
  final String content;
  final String hash_tag;
  final String comments;
  final int post_id;
  final DateTime created_at;

  Post({
    required this.images_url,
    required this.original,
    required this.title,
    required this.content,
    required this.hash_tag,
    required this.comments,
    required this.post_id,
    required this.created_at,
  });
}

class UserService {
  // Singleton 인스턴스 생성
  static final UserService _instance = UserService._internal();

  // 외부에서 사용할 List<Map> 형태의 사용자 및 포스트 데이터
  List<Map<String, dynamic>> usersData = [];
  List<Map<String, dynamic>> postsData = [];

  Map<int, List<Post>> postsMap = {};

  // 내부 생성자
  UserService._internal();

  // Singleton 인스턴스 반환
  factory UserService() {
    return _instance;
  }

  // usersData를 기반으로 Friend Map 생성
  static Map<int, Friend> getFriends(List<Map<String, dynamic>> usersData) {
    final Map<int, Friend> friendsMap = {};

    for (var user in usersData) {
      try {
        final friend = Friend(
          user_id: user['user_id'] as int,
          nickname: user['nickname'] as String,
          name: user['name'] as String,
          sex: user['sex'] as String,
          age: user['age'] as int,
          profile_image_url: user['profile_image_url'] as String,
          bio: user['bio'] as String,
          friend_ship: user['friend_ship'] != null ? user['friend_ship'] : false,
          hair_style: user['hair_style'] as String,
          glasses: user['glasses'] as String,
          body_type: user['body_type'] as String,
        );
        friendsMap[friend.user_id] = friend; // user_id를 키로 사용
      } catch (error) {
        print('Error parsing user data: $user. Error: $error');
      }
    }

    return friendsMap;
  }

  // 특정 유저의 게시물 가져오기
  List<Post> getPosts(int userId) {
    return postsMap[userId] ?? [];
  }

  // 특정 유저의 게시물 사진만 가져오기
  List<String> getPostImages(int userId) {
    if (!postsMap.containsKey(userId) || postsMap[userId] == null) {
      return []; // userId에 해당하는 데이터가 없으면 빈 리스트 반환
    }

    return postsMap[userId]!
        .expand((post) => post.images_url) // 각 게시물의 images_url을 펼침
        .toList(); // 합친 리스트를 반환
  }

  // 이미지 중 랜덤한 하나를 가져오는 함수
  String? getRandomPostImage(int userId) {
    final images = getPostImages(userId);
    if (images.isEmpty) return null; // 이미지가 없으면 null 반환

    final random = Random();
    return images[random.nextInt(images.length)]; // 랜덤한 이미지 선택
  }

  // 유저별 가장 최근 게시물의 addedDate 기준으로 정렬된 유저 ID 리스트 반환
  List<int> getUsersSortedByMostRecentPost() {
    // 각 유저별 가장 최근 게시물 날짜를 찾음
    final userLatestPosts = postsMap.map((userId, posts) {
      // 게시물이 없는 경우 기본값 사용
      final mostRecentDate = posts.isNotEmpty
          ? posts.map((post) => post.created_at).reduce((a, b) => a.isAfter(b) ? a : b)
          : DateTime(1970, 1, 1); // 기본값
      return MapEntry(userId, mostRecentDate);
    });

    // 날짜를 기준으로 유저 ID 정렬
    final sortedUserIds = userLatestPosts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // 가장 최근 날짜 기준 내림차순 정렬

    // 정렬된 유저 ID 리스트 반환
    return sortedUserIds.map((entry) => entry.key).toList();
  }

  // 사용자 데이터를 호출하고 저장하는 함수
  Future<void> fetchUsersData() async {
    for (int userId = 1; userId <= 10; userId++) {
      final url = Uri.parse('http://52.78.132.208:8002/users/$userId'); // 각 사용자 URL 생성
      try {
        final response = await http.get(url); // GET 요청 보내기
        if (response.statusCode == 200) {
          // UTF-8로 디코딩
          final decodedBody = utf8.decode(response.bodyBytes);
          final data = json.decode(decodedBody) as Map<String, dynamic>; // JSON 디코딩
          usersData.add(data); // 리스트에 추가
        } else {
          print('Failed to load user $userId. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching user $userId: $error'); // 에러 처리
      }
    }
  }

  Future<void> fetchPostsData() async {
    // 유저 ID 목록 생성 (1부터 10까지)
    final List<int> userIds = List.generate(10, (index) => index + 1);

    for (final userId in userIds) {
      final url = Uri.parse('http://52.78.132.208:8002/posts/$userId'); // 각 유저의 게시물 URL 생성
      try {
        final response = await http.get(url); // GET 요청 보내기
        if (response.statusCode == 200) {
          // UTF-8로 디코딩하여 JSON 파싱
          final decodedBody = utf8.decode(response.bodyBytes);
          final data = json.decode(decodedBody); // JSON 디코딩

          // posts 데이터를 저장할 리스트 초기화
          final List<Post> posts = [];

          if (data is List) {
            // 반환값이 List<dynamic>인 경우
            for (var item in data) {
              if (item is Map<String, dynamic>) {
                try {
                  // Post 객체 생성 및 리스트에 추가
                  final post = Post(
                    images_url: (item['images_url'] as String)
                        .split(RegExp(r',\s*')) // 콤마 뒤에 공백이 있든 없든 정상 처리
                        .map((url) => url.trim()) // 각 URL의 공백 제거
                        .toList(),
                    original: item['original'] as String,
                    title: item['title'] as String,
                    content: item['content'] as String,
                    hash_tag: item['hash_tag'] as String,
                    comments: item['comments'] ?? "0",
                    post_id: item['post_id'] as int,
                    created_at: DateTime.tryParse(item['created_at'] as String) ??
                        (throw FormatException("Invalid date format for created_at: ${item['created_at']}")),
                  );
                  posts.add(post);
                } catch (error) {
                  print('Error parsing post for user $userId: $error');
                }
              } else {
                print('Invalid item type in posts for user $userId: $item');
              }
            }
          } else {
            print('Unexpected data type for posts of user $userId: $data');
          }

          // postsMap에 userId를 키로 하여 게시물 추가
          postsMap[userId] = posts;
        } else {
          // 상태 코드가 200이 아닌 경우 처리
          print('Failed to load posts for user $userId. Status code: ${response.statusCode}');
        }
      } catch (error) {
        // 예외 처리
        print('Error fetching posts for user $userId: $error');
      }
    }
  }

  // 사용자 및 포스트 데이터를 모두 호출하는 함수
  Future<void> fetchAllData() async {
    await Future.wait([fetchUsersData(), fetchPostsData()]); // 두 데이터를 동시에 호출
  }
}
