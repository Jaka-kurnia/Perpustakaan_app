import 'package:flutter/material.dart';
import 'package:perpustakaan_app/screens/book/book_list_screen.dart';
import 'package:perpustakaan_app/screens/users/user_list_screen.dart';
import '../screens/splash_screen.dart';
// import '../dashboard_admin/home_screen.dart';
import '../dashboard_user/home_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const adminHome = '/admin-home';
  static const bookList = '/book-list';
  static const userList = '/user-list';
  static const String userHome = '/user-home';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    userHome: (context) => const HomeScreen(),
    bookList: (context) => const BookListScreen(),
    userList: (context) => const UserListScreen(),
  };
}
