import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quizletapp/enums/text_style_enum.dart';
import 'package:quizletapp/utils/app_theme.dart';
import 'package:quizletapp/widgets/elevatedButton.dart';
import '../widgets/text.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Set up a periodic timer to change the page every 5 seconds
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < 3) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColorAppbar,
      appBar: AppBar(
        title: CustomText(
          text: 'Quizlet',
          type: TextStyleEnum.xxl,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.grey,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
        ],
        backgroundColor: AppTheme.primaryBackgroundColorAppbar,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildPage(
                    imageUrl: 'assets/images/image1.jpg',
                    text:
                        'Hơn 90% học sinh sử dụng Quizlet cho biết họ đã cải thiện được diểm số',
                    textStyle: TextStyleEnum.large),
                _buildPage(
                    imageUrl: 'assets/images/image2.jpg',
                    text: 'Tìm kiếm hàng triệu bộ thẻ ghi nhớ',
                    textStyle: TextStyleEnum.xl),
                _buildPage(
                    imageUrl: 'assets/images/image3.jpg',
                    text: 'Học bằng bốn cách khác nhau',
                    textStyle: TextStyleEnum.xl),
                _buildPage(
                    imageUrl: 'assets/images/image4.png',
                    text: 'Tùy chỉnh thẻ ghi nhớ theo nhu cầu của bạn',
                    textStyle: TextStyleEnum.xl),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(4, (int index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  width: _currentPage == index ? 12.0 : 8.0,
                  height: _currentPage == index ? 12.0 : 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.white : Colors.grey,
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  text: 'Đăng ký miễn phí',
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: CustomText(
                    text: 'Hoặc đăng nhập',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildPage(
      {required String imageUrl,
      required String text,
      required TextStyleEnum textStyle}) {
    // Lấy kích thước màn hình
    final Size screenSize = MediaQuery.of(context).size;
    // Tính toán width của hình ảnh dựa trên kích thước màn hình
    final double imageWidth = screenSize.width - 50;
    // Tính toán height của hình ảnh dựa trên width
    final double imageHeight = imageWidth * (250 / 350); // Tỷ lệ ảnh
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Image.asset(
            imageUrl,
            height: imageHeight,
            width: imageWidth,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: CustomText(
            text: text,
            type: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
