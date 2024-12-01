import 'package:flutter/material.dart';
import 'UserData.dart';

class PostPage extends StatefulWidget {
  final VoidCallback onGoBack;
  final int userId;

  PostPage({required this.onGoBack, required this.userId});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late Future<List<Post>> _postsFuture;
  late List<PageController> _pageControllers;
  late List<int> _currentPages;
  late List<bool> _contentExpanded;
  late List<bool> _titleExpanded;

  @override
  void initState() {
    super.initState();
    print('PostPage initialized for userId: ${widget.userId}');
    _postsFuture = _fetchPosts();
  }

  Future<List<Post>> _fetchPosts() async {
    try {
      print('Fetching posts for userId: ${widget.userId}');
      await UserService().fetchPostsData(); // 비동기적으로 게시물 데이터 로드
      final posts = UserService().getPosts(widget.userId);
      print('Posts fetched: ${posts.length} for userId: ${widget.userId}');

      if (posts.isEmpty) {
        throw Exception('No posts found for userId: ${widget.userId}');
      }

      _initializeControllers(posts.length); // 컨트롤러 초기화
      return posts;
    } catch (e) {
      print('Error in _fetchPosts: $e');
      throw Exception('Failed to fetch posts: $e');
    }
  }

  void _initializeControllers(int postCount) {
    _pageControllers = List.generate(postCount, (_) => PageController());
    _currentPages = List.generate(postCount, (_) => 0);
    _contentExpanded = List.generate(postCount, (_) => false);
    _titleExpanded = List.generate(postCount, (_) => false);
  }

  @override
  void dispose() {
    for (var controller in _pageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? getImagePath(Post post, int pageIndex) {
    if (pageIndex < post.images_url.length) {
      return post.images_url[pageIndex];
    }
    return null; // 이미지 경로가 유효하지 않을 경우 null 반환
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 로딩 중
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              '게시물을 불러오지 못했습니다.\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ); // 에러 처리
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              '게시물이 없습니다.',
              style: TextStyle(fontSize: 18),
            ),
          ); // 게시물 없음 처리
        }

        final posts = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final images = post.images_url.where((img) => img.isNotEmpty).toList();
                  final pageCount = images.length;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.095,
                              height: MediaQuery.of(context).size.width * 0.095,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: UserService.getFriends(UserService().usersData)[widget.userId]?.profile_image_url.isNotEmpty ?? false
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  UserService.getFriends(UserService().usersData)[widget.userId]!.profile_image_url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.error,
                                      size: 32,
                                      color: Colors.red,
                                    );
                                  },
                                ),
                              )
                                  : Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                UserService.getFriends(UserService().usersData)[widget.userId]?.name ?? '',
                                style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: Offset(0, 14),
                                  blurRadius: 18,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.45,
                                    child: PageView.builder(
                                      controller: _pageControllers[index],
                                      itemCount: pageCount,
                                      onPageChanged: (page) {
                                        setState(() {
                                          _currentPages[index] = page;
                                        });
                                      },
                                      itemBuilder: (context, pageIndex) {
                                        final imagePath = getImagePath(post, pageIndex);
                                        if (imagePath != null && imagePath.isNotEmpty) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              image: DecorationImage(
                                                image: NetworkImage(imagePath),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        }
                                        return SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _titleExpanded[index] = !_titleExpanded[index];
                                      });
                                    },
                                    child: Text(
                                      post.title,
                                      style: TextStyle(
                                        fontFamily: 'NotoSans',
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: _titleExpanded[index] ? null : 2,
                                      overflow: _titleExpanded[index]
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _contentExpanded[index] = !_contentExpanded[index];
                                      });
                                    },
                                    child: Text(
                                      post.content,
                                      style: TextStyle(fontSize: 18),
                                      maxLines: _contentExpanded[index] ? null : 2,
                                      overflow: _contentExpanded[index]
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(height: 40, color: Colors.black12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
