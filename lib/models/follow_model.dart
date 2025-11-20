class Follow {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String createdAt;

  Follow({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) => Follow(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    avatar: json['avatar'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar': avatar,
    'created_at': createdAt,
  };
}

class FollowResponse {
  final List<Follow> followers;
  final List<Follow> following;

  FollowResponse({
    required this.followers,
    required this.following,
  });

  factory FollowResponse.fromJson(Map<String, dynamic> json) => FollowResponse(
    followers: (json['followers'] as List)
        .map((f) => Follow.fromJson(f))
        .toList(),
    following: (json['following'] as List)
        .map((f) => Follow.fromJson(f))
        .toList(),
  );
}