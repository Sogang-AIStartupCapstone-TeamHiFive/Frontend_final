import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'UserData.dart';

class PostDetailsPage extends StatelessWidget {
  final Post post;

  PostDetailsPage({required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0, // 제목과 아이콘 사이의 간격 제거
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 35, color: Colors.black54), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.of(context).pop(); // 이전 화면으로 돌아가기
          },
        ),
        title: Align(
          alignment: Alignment.centerLeft, // 텍스트를 아이콘 바로 오른쪽에 배치
          child: Text(
            '뒤로 가기',
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 24, // 더 작고 정돈된 텍스트 크기
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.images_url.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 200,
                      autoPlay: post.images_url.length > 1, // 이미지가 2개 이상일 때만 자동 슬라이드
                      enlargeCenterPage: true,
                    ),
                    items: post.images_url.map((url) {
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.error,
                            size: 50,
                            color: Colors.red,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16),
              ],
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      post.content,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 20,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatHashTags(post.hash_tag)}',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '댓글 수: ${post.comments}',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // 새로운 댓글 박스
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '댓글',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    // 댓글 내용 표시
                    Text(
                      post.comments, // post.comments에 있는 내용을 댓글로 표시
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatHashTags(String hashTags) {
    // 쉼표로 구분된 해시태그 문자열에 각각 #을 추가
    return hashTags
        .split(',')
        .map((tag) => '#${tag.trim()}')
        .join(' ');
  }
}
