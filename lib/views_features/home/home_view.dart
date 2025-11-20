import 'package:betweeener_app/providers/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/providers/user_provider.dart';
import 'package:betweeener_app/views_features/auth/login_view.dart';
import 'package:betweeener_app/views_features/links/add_link_view.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomeView extends StatefulWidget {
  static const String id = '/home';
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final linksProvider = Provider.of<LinksProvider>(context, listen: false);
    await linksProvider.loadUserLinks();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final linksProvider = Provider.of<LinksProvider>(context);

    return Scaffold(
      backgroundColor: kScaffoldColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userProvider.currentUser != null
                          ? 'Hello, ${userProvider.currentUser!.user.name.split(' ').first}!'
                          : 'Hello!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        await userProvider.logout();
                        if (mounted) {
                          Navigator.pushReplacementNamed(context, LoginView.id);
                        }
                      },
                      icon: const Icon(Icons.logout, color: kRedColor, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: linksProvider.isLoading
                        ? const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                        : QrImageView(
                      data: 'betweener://user/${userProvider.currentUser?.user.id ?? 0}',
                      size: 200,
                      foregroundColor: kPrimaryColor,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                const Text('Your Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                linksProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : linksProvider.userLinks.isEmpty
                    ? Center(child: _buildAddNewButton())
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: linksProvider.userLinks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == linksProvider.userLinks.length) return _buildAddNewButton();
                    final link = linksProvider.userLinks[index];
                    return _buildLinkButton(
                      link.title,
                      link.username ?? link.link.split('/').last,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkButton(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: kLightSecondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kOnSecondaryColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: kOnSecondaryColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(context, AddLinkView.id);
        if (result == true) _loadData();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPrimaryColor, width: 2),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: kPrimaryColor, size: 30),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Add new', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}