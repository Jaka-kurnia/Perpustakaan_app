import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart'; // Pastikan import ini ada
import '../dashboard_admin/home_screen.dart' as admin;
import '../dashboard_user/home_screen.dart' as user;
import '../screens/book/book_list_screen.dart';
import '../screens/users/user_list_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String adminHome = '/admin-home';
  static const String userHome = '/user-home';
  static const String bookList = '/book-list';
  static const String userList = '/user-list';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(), // Tambahkan rute login
        adminHome: (context) => const admin.HomeScreen(), // Dashboard Admin
        userHome: (context) => const user.HomeScreen(),   // Dashboard User
        bookList: (context) => const BookListScreen(),
        userList: (context) => const UserListScreen(),
      };
}