import 'package:flutter/material.dart';
import 'package:perpustakaan_app/screens/book/book_list_screen.dart';
import '../screens/splash_screen.dart';
import '../dashboard_admin/home_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const adminHome = '/admin-home';
  static const bookList = '/book-list';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    adminHome: (context) => const HomeScreen(),
    bookList: (context) => const BookListScreen(),
  };
}
