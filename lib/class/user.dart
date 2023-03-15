import 'package:rs_tools/rs_tools.dart';

class User extends RSObject {
  User({
    Map<String, dynamic>? data,
    required String documentId,
  }) : super(data, collectionName: 'users', documentId: documentId);

  User.fromMap(Map? data)
      : super.fromMap(
          data: data,
          documentId: data?['uid'] ?? 'noId',
          collectionName: 'users',
        );
  static User empty = User(documentId: '');
  String? get displayName => stringFromKey('displayName');
  set displayName(String? displayName) => setObject('displayName', displayName);

  String? get email => stringFromKey('email');
  set email(String? email) => setObject('email', email);

  String? get photoURL => stringFromKey('photoURL');
  set photoURL(String? photoURL) => setObject('photoURL', photoURL);

  @override
  List<Object?> get props => [
        ...super.props,
        displayName,
        photoURL,
        email,
      ];
}
