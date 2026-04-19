part of 'generated.dart';

class CreateUserVariablesBuilder {
  String uid;
  String email;
  String name;
  String role;
  final Optional<String> _studentId = Optional.optional(nativeFromJson, nativeToJson);
  final Optional<String> _program = Optional.optional(nativeFromJson, nativeToJson);
  final Optional<int> _year = Optional.optional(nativeFromJson, nativeToJson);
  final Optional<String> _department = Optional.optional(nativeFromJson, nativeToJson);
  final Optional<String> _photoUrl = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateUserVariablesBuilder studentId(String? t) {
   _studentId.value = t;
   return this;
  }
  CreateUserVariablesBuilder program(String? t) {
   _program.value = t;
   return this;
  }
  CreateUserVariablesBuilder year(int? t) {
   _year.value = t;
   return this;
  }
  CreateUserVariablesBuilder department(String? t) {
   _department.value = t;
   return this;
  }
  CreateUserVariablesBuilder photoUrl(String? t) {
   _photoUrl.value = t;
   return this;
  }

  CreateUserVariablesBuilder(this._dataConnect, {required  this.uid,required  this.email,required  this.name,required  this.role,});
  Deserializer<CreateUserData> dataDeserializer = (dynamic json)  => CreateUserData.fromJson(jsonDecode(json));
  Serializer<CreateUserVariables> varsSerializer = (CreateUserVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateUserData, CreateUserVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateUserData, CreateUserVariables> ref() {
    CreateUserVariables vars= CreateUserVariables(uid: uid,email: email,name: name,role: role,studentId: _studentId,program: _program,year: _year,department: _department,photoUrl: _photoUrl,);
    return _dataConnect.mutation("CreateUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateUserUserInsert {
  final String id;
  CreateUserUserInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserUserInsert otherTyped = other as CreateUserUserInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateUserUserInsert({
    required this.id,
  });
}

@immutable
class CreateUserData {
  final CreateUserUserInsert user_insert;
  CreateUserData.fromJson(dynamic json):
  
  user_insert = CreateUserUserInsert.fromJson(json['user_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserData otherTyped = other as CreateUserData;
    return user_insert == otherTyped.user_insert;
    
  }
  @override
  int get hashCode => user_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user_insert'] = user_insert.toJson();
    return json;
  }

  const CreateUserData({
    required this.user_insert,
  });
}

@immutable
class CreateUserVariables {
  final String uid;
  final String email;
  final String name;
  final String role;
  late final Optional<String>studentId;
  late final Optional<String>program;
  late final Optional<int>year;
  late final Optional<String>department;
  late final Optional<String>photoUrl;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateUserVariables.fromJson(Map<String, dynamic> json):
  
  uid = nativeFromJson<String>(json['uid']),
  email = nativeFromJson<String>(json['email']),
  name = nativeFromJson<String>(json['name']),
  role = nativeFromJson<String>(json['role']) {
  
  
  
  
  
  
    studentId = Optional.optional(nativeFromJson, nativeToJson);
    studentId.value = json['studentId'] == null ? null : nativeFromJson<String>(json['studentId']);
  
  
    program = Optional.optional(nativeFromJson, nativeToJson);
    program.value = json['program'] == null ? null : nativeFromJson<String>(json['program']);
  
  
    year = Optional.optional(nativeFromJson, nativeToJson);
    year.value = json['year'] == null ? null : nativeFromJson<int>(json['year']);
  
  
    department = Optional.optional(nativeFromJson, nativeToJson);
    department.value = json['department'] == null ? null : nativeFromJson<String>(json['department']);
  
  
    photoUrl = Optional.optional(nativeFromJson, nativeToJson);
    photoUrl.value = json['photoUrl'] == null ? null : nativeFromJson<String>(json['photoUrl']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUserVariables otherTyped = other as CreateUserVariables;
    return uid == otherTyped.uid && 
    email == otherTyped.email && 
    name == otherTyped.name && 
    role == otherTyped.role && 
    studentId == otherTyped.studentId && 
    program == otherTyped.program && 
    year == otherTyped.year && 
    department == otherTyped.department && 
    photoUrl == otherTyped.photoUrl;
    
  }
  @override
  int get hashCode => Object.hashAll([uid.hashCode, email.hashCode, name.hashCode, role.hashCode, studentId.hashCode, program.hashCode, year.hashCode, department.hashCode, photoUrl.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['uid'] = nativeToJson<String>(uid);
    json['email'] = nativeToJson<String>(email);
    json['name'] = nativeToJson<String>(name);
    json['role'] = nativeToJson<String>(role);
    if(studentId.state == OptionalState.set) {
      json['studentId'] = studentId.toJson();
    }
    if(program.state == OptionalState.set) {
      json['program'] = program.toJson();
    }
    if(year.state == OptionalState.set) {
      json['year'] = year.toJson();
    }
    if(department.state == OptionalState.set) {
      json['department'] = department.toJson();
    }
    if(photoUrl.state == OptionalState.set) {
      json['photoUrl'] = photoUrl.toJson();
    }
    return json;
  }

  CreateUserVariables({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.studentId,
    required this.program,
    required this.year,
    required this.department,
    required this.photoUrl,
  });
}

