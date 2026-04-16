import 'dart:convert';

ResponseLogin responseLoginFromJson(String str) => ResponseLogin.fromJson(json.decode(str));

String responseLoginToJson(ResponseLogin data) => json.encode(data.toJson());

class ResponseLogin {
    String token;
    User user;

    ResponseLogin({
        required this.token,
        required this.user,
    });

    factory ResponseLogin.fromJson(Map<String, dynamic> json) => ResponseLogin(
        token: json["token"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "user": user.toJson(),
    };
}

class User {
    String email;
    int id;
    String name;
    String role;

    User({
        required this.email,
        required this.id,
        required this.name,
        required this.role,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        email: json["email"],
        id: json["id"],
        name: json["name"],
        role: json["role"],
    );

    Map<String, dynamic> toJson() => {
        "email": email,
        "id": id,
        "name": name,
        "role": role,
    };
}