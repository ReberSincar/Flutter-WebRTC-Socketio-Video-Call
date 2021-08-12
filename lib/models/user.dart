class User {
  User({
    this.username,
    this.name,
    this.surname,
  });

  String? username;
  String? name;
  String? surname;

  factory User.fromJson(Map<String, dynamic> json) => User(
        username: json["username"],
        name: json["name"],
        surname: json["surname"],
      );

  Map<String, dynamic> toJson() => {
        "username": username,
        "name": name,
        "surname": surname,
      };
}
