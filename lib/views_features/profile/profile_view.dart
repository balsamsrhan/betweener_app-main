import 'package:betweeener_app/models/link_response_model.dart';
import 'package:betweeener_app/models/user.dart';
import 'package:betweeener_app/providers/link_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/providers/user_provider.dart';
import 'package:betweeener_app/views_features/links/add_link_view.dart';
import 'package:betweeener_app/views_features/links/edit_link.dart';
import 'package:betweeener_app/views_features/profile/edit_profile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileView extends StatefulWidget {
  static const id = '/profileView';
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: () {
            //  Navigator.pushNamed(context, FollowersView.id);
            },
            tooltip: 'Followers & Following',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Links',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (userProvider.currentUser != null)
                _userCard(userProvider.currentUser!.user)
              else if (userProvider.isLoading)
                const CircularProgressIndicator()
              else
                const Text('No user data'),

              const SizedBox(height: 32),

              linksProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : linksProvider.userLinks.isEmpty
                  ? const Center(
                child: Text(
                  'No links yet.\nTap + to add your first!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: linksProvider.userLinks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) => _linkCard(linksProvider.userLinks[i]),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AddLinkView.id);
          if (result == true) _loadData();
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _userCard(UserClass user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=${user.id}'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(user.email, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      _followChip('followers 203', kSecondaryColor),
                      const SizedBox(width: 12),
                      _followChip('following 100', kSecondaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileView()),
              );
              if (result == true) {
                _loadData();
              }
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _followChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _linkCard(LinkElement link) {
    final isActive = link.isActive == 1;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Slidable(
        key: Key(link.id.toString()),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditLinkView(link: link)),
                );
                if (result == true) {
                  _loadData();
                }
              },
              backgroundColor: kSecondaryColor,
              foregroundColor: Colors.black87,
              icon: Icons.edit,
              label: 'Edit',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _showDeleteDialog(link),
              backgroundColor: kDangerColor,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? kLightSecondaryColor : kLightPrimaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.title.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: kOnSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => launchUrl(
                        Uri.parse(link.link),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Text(
                        link.link,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
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
// في دالة _showDeleteDialog فقط، عدل هذا الجزء:
  void _showDeleteDialog(LinkElement link) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Link?'),
        content: Text('Remove "${link.title}" permanently?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kDangerColor),
            onPressed: () async {
              Navigator.pop(context);

              final linksProvider = Provider.of<LinksProvider>(context, listen: false);
              await linksProvider.deleteLink(link.id);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${link.title} deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}