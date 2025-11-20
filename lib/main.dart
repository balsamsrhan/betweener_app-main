import 'package:betweeener_app/models/link_response_model.dart';
import 'package:betweeener_app/providers/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:betweeener_app/views_features/auth/login_view.dart';
import 'package:betweeener_app/views_features/auth/register_view.dart';
import 'package:betweeener_app/views_features/main_app_view.dart';
import 'package:betweeener_app/views_features/home/home_view.dart';
import 'package:betweeener_app/views_features/profile/profile_view.dart';
import 'package:betweeener_app/views_features/links/add_link_view.dart';
import 'package:betweeener_app/views_features/links/edit_link.dart';
import 'package:betweeener_app/views_features/profile/edit_profile.dart';
import 'package:betweeener_app/views_features/follow/followers_view.dart';
import 'package:betweeener_app/views_features/search/search_view.dart';
import 'package:betweeener_app/providers/user_provider.dart';
import 'package:betweeener_app/providers/follow_provider.dart';

import 'views_features/recieve/receive_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LinksProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
      ],
      child: MaterialApp(
        title: 'Betweeener',
        theme: ThemeData(
          primaryColor: const Color(0xff2D2B4E),
          scaffoldBackgroundColor: const Color(0xffFDFDFD),
        ),
        home: AppLoader(),
        routes: {
          LoginView.id: (context) => LoginView(),
          RegisterView.id: (context) => RegisterView(),
          MainAppView.id: (context) => MainAppView(),
          HomeView.id: (context) => HomeView(),
          ProfileView.id: (context) => ProfileView(),
          AddLinkView.id: (context) => AddLinkView(),
          EditLinkView.id: (context) => EditLinkView(
            link: ModalRoute.of(context)!.settings.arguments as LinkElement,
          ),
          EditProfileView.id: (context) => const EditProfileView(),
          FollowersView.id: (context) => const FollowersView(),
          SearchView.id: (context) => const SearchView(),
          ReceiveView.id: (context) => const ReceiveView(),
        },
        // أو استخدم onGenerateRoute للطرق الديناميكية
        onGenerateRoute: (settings) {
          // معالجة الطرق التي تحتاج arguments
          if (settings.name == EditLinkView.id) {
            final link = settings.arguments as LinkElement;
            return MaterialPageRoute(
              builder: (context) => EditLinkView(link: link),
            );
          }
          return null;
        },
      ),
    );
  }
}

class AppLoader extends StatefulWidget {
  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserFromStorage();

    if (userProvider.isLoggedIn) {
      final linksProvider = Provider.of<LinksProvider>(context, listen: false);
      await linksProvider.loadUserLinks();

      Navigator.pushReplacementNamed(context, MainAppView.id);
    } else {
      Navigator.pushReplacementNamed(context, LoginView.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDFDFD),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}