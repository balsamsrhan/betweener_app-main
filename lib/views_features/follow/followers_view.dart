import 'package:betweeener_app/models/follow_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/providers/follow_provider.dart';
import 'package:betweeener_app/views_features/profile/user_profile_view.dart';

class FollowersView extends StatefulWidget {
  static const String id = '/followersView';

  const FollowersView({super.key});

  @override
  State<FollowersView> createState() => _FollowersViewState();
}

class _FollowersViewState extends State<FollowersView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final followProvider = Provider.of<FollowProvider>(context, listen: false);
    await followProvider.loadFollowData();
  }

  @override
  Widget build(BuildContext context) {
    final followProvider = Provider.of<FollowProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kScaffoldColor,
        appBar: AppBar(
          title: const Text('Followers & Following'),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: kSecondaryColor,
            labelColor: kPrimaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: followProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _loadData,
          child: TabBarView(
            children: [
              _buildUsersList(followProvider.followers, isFollowing: false),
              _buildUsersList(followProvider.following, isFollowing: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList(List<Follow> users, {required bool isFollowing}) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          isFollowing ? 'Not following anyone' : 'No followers yet',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                user.avatar ?? 'https://i.pravatar.cc/150?u=${user.id}',
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(user.email),
            trailing: isFollowing
                ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kDangerColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _unfollowUser(user.id),
              child: const Text('Unfollow'),
            )
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryColor,
                foregroundColor: Colors.black,
              ),
              onPressed: () => _followUser(user.id),
              child: const Text('Follow Back'),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileView(userId: user.id, userName: user.name),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _followUser(int userId) async {
    final followProvider = Provider.of<FollowProvider>(context, listen: false);
    await followProvider.followUser(userId);
  }

  Future<void> _unfollowUser(int userId) async {
    final followProvider = Provider.of<FollowProvider>(context, listen: false);
    await followProvider.unfollowUser(userId);
  }
}