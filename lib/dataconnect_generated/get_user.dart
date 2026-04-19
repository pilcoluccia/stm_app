part of 'generated.dart';

class GetUserVariablesBuilder {
  String uid;

  final FirebaseDataConnect _dataConnect;
  GetUserVariablesBuilder(this._dataConnect, {required  this.uid,});
  Deserializer<GetUserData> dataDeserializer = (dynamic json)  => GetUserData.fromJson(jsonDecode(json));
  Serializer<GetUserVariables> varsSerializer = (GetUserVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetUserData, GetUserVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetUserData, GetUserVariables> ref() {
    GetUserVariables vars= GetUserVariables(uid: uid,);
    return _dataConnect.query("GetUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetUserUsers {
  final String id;
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? studentId;
  final String? program;
  final int? year;
  final String? department;
  final String? photoUrl;
  final Timestamp createdAt;
  GetUserUsers.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  uid = nativeFromJson<String>(json['uid']),
  email = nativeFromJson<String>(json['email']),
  name = nativeFromJson<String>(json['name']),
  role = nativeFromJson<String>(json['role']),
  studentId = json['studentId'] == null ? null : nativeFromJson<String>(json['studentId']),
  program = json['program'] == null ? null : nativeFromJson<String>(json['program']),
  year = json['year'] == null ? null : nativeFromJson<int>(json['year']),
  department = json['department'] == null ? null : nativeFromJson<String>(json['department']),
  photoUrl = json['photoUrl'] == null ? null : nativeFromJson<String>(json['photoUrl']),
  createdAt = Timestamp.fromJson(json['createdAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserUsers otherTyped = other as GetUserUsers;
    return id == otherTyped.id && 
    uid == otherTyped.uid && 
    email == otherTyped.email && 
    name == otherTyped.name && 
    role == otherTyped.role && 
    studentId == otherTyped.studentId && 
    program == otherTyped.program && 
    year == otherTyped.year && 
    department == otherTyped.department && 
    photoUrl == otherTyped.photoUrl && 
    createdAt == otherTyped.createdAt;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, uid.hashCode, email.hashCode, name.hashCode, role.hashCode, studentId.hashCode, program.hashCode, year.hashCode, department.hashCode, photoUrl.hashCode, createdAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['uid'] = nativeToJson<String>(uid);
    json['email'] = nativeToJson<String>(email);
    json['name'] = nativeToJson<String>(name);
    json['role'] = nativeToJson<String>(role);
    if (studentId != null) {
      json['studentId'] = nativeToJson<String?>(studentId);
    }
    if (program != null) {
      json['program'] = nativeToJson<String?>(program);
    }
    if (year != null) {
      json['year'] = nativeToJson<int?>(year);
    }
    if (department != null) {
      json['department'] = nativeToJson<String?>(department);
    }
    if (photoUrl != null) {
      json['photoUrl'] = nativeToJson<String?>(photoUrl);
    }
    json['createdAt'] = createdAt.toJson();
    return json;
  }

  GetUserUsers({
    required this.id,
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.studentId,
    this.program,
    this.year,
    this.department,
    this.photoUrl,
    required this.createdAt,
  });
}

@immutable
class GetUserData {
  final List<GetUserUsers> users;
  GetUserData.fromJson(dynamic json):
  
  users = (json['users'] as List<dynamic>)
        .map((e) => GetUserUsers.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserData otherTyped = other as GetUserData;
    return users == otherTyped.users;
    
  }
  @override
  int get hashCode => users.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['users'] = users.map((e) => e.toJson()).toList();
    return json;
  }

  GetUserData({
    required this.users,
  });
}

@immutable
class GetUserVariables {
  final String uid;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetUserVariables.fromJson(Map<String, dynamic> json):
  
  uid = nativeFromJson<String>(json['uid']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserVariables otherTyped = other as GetUserVariables;
    return uid == otherTyped.uid;
    
  }
  @override
  int get hashCode => uid.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['uid'] = nativeToJson<String>(uid);
    return json;
  }

  GetUserVariables({
    required this.uid,
  });
}

