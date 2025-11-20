import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:betweeener_app/controllers/follow_controller.dart';
import 'package:betweeener_app/controllers/search_controller.dart';
import 'package:betweeener_app/core/util/constants.dart';
import 'package:betweeener_app/models/link_response_model.dart';
import 'package:betweeener_app/models/user.dart';
import 'package:betweeener_app/providers/follow_provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileView extends StatefulWidget {
  final int userId;
  final String? userName;

  const UserProfileView({super.key, required this.userId, this.userName});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  UserClass? _user;
  List<LinkElement> _links = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _checkIfFollowing();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await SearchController2.getUserProfile(widget.userId);
      setState(() {
        _user = UserClass.fromJson(data['user']);
        _links = (data['links'] as List)
            .map((link) => LinkElement.fromJson(link))
            .toList()
            .cast<LinkElement>();

        _followersCount = data['followers_count'] ?? 0;
        _followingCount = data['following_count'] ?? 0;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkIfFollowing() async {
    try {
      setState(() => _isFollowing = false);
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    try {
      if (_isFollowing) {
        final followProvider = Provider.of<FollowProvider>(context, listen: false);
        await followProvider.unfollowUser(widget.userId);
        setState(() {
          _isFollowing = false;
          _followersCount = _followersCount > 0 ? _followersCount - 1 : 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unfollowed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final followProvider = Provider.of<FollowProvider>(context, listen: false);
        await followProvider.followUser(widget.userId);
        setState(() {
          _isFollowing = true;
          _followersCount += 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Followed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kScaffoldColor,
      appBar: AppBar(
        title: Text(widget.userName ?? 'Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: kPrimaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text('User not found'))
          : RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildUserCard(),
              const SizedBox(height: 24),
              _buildFollowButton(),
              const SizedBox(height: 32),
              if (_links.isNotEmpty) ...[
                const Text(
                  'Links',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ..._links.map((link) => _buildLinkCard(link)),
              ] else ...[
                const Text(
                  'No links available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/300?u=${_user!.id}',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _user!.email,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCountCard('Followers', _followersCount),
              _buildCountCard('Following', _followingCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountCard(String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _toggleFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFollowing ? kDangerColor : kSecondaryColor,
          foregroundColor: _isFollowing ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _isFollowing ? 'Unfollow' : 'Follow',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLinkCard(LinkElement link) {
    final isActive = link.isActive == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? kLightSecondaryColor : kLightPrimaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? kSecondaryColor : kLinksColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? kSecondaryColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getLinkIcon(link.title),
              color: isActive ? Colors.black : kPrimaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.title.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isActive ? kOnSecondaryColor : kLinksColor,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _launchLink(link.link),
                  child: Text(
                    link.username ?? _getDisplayLink(link.link),
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.blue : kLinksColor,
                      decoration: isActive ? TextDecoration.underline : TextDecoration.none,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (isActive) ...[
            IconButton(
              icon: const Icon(Icons.open_in_new, color: kPrimaryColor, size: 20),
              onPressed: () => _launchLink(link.link),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getLinkIcon(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('facebook')) return Icons.facebook;
    if (lowerTitle.contains('instagram')) return Icons.camera_alt;
    if (lowerTitle.contains('twitter') || lowerTitle.contains('x')) return Icons.trending_up;
    if (lowerTitle.contains('linkedin')) return Icons.business;
    if (lowerTitle.contains('youtube')) return Icons.play_circle_filled;
    if (lowerTitle.contains('whatsapp')) return Icons.chat;
    if (lowerTitle.contains('tiktok')) return Icons.music_note;
    if (lowerTitle.contains('snapchat')) return Icons.camera_alt;
    return Icons.link;
  }

  String _getDisplayLink(String link) {
    try {
      final uri = Uri.parse(link);
      return '${uri.host}${uri.path}';
    } catch (e) {
      return link.length > 30 ? '${link.substring(0, 30)}...' : link;
    }
  }

  Future<void> _launchLink(String link) async {
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot open this link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}