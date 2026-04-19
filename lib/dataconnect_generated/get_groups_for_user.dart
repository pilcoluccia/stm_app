part of 'generated.dart';

class GetGroupsForUserVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  GetGroupsForUserVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<GetGroupsForUserData> dataDeserializer = (dynamic json)  => GetGroupsForUserData.fromJson(jsonDecode(json));
  Serializer<GetGroupsForUserVariables> varsSerializer = (GetGroupsForUserVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetGroupsForUserData, GetGroupsForUserVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetGroupsForUserData, GetGroupsForUserVariables> ref() {
    GetGroupsForUserVariables vars= GetGroupsForUserVariables(userId: userId,);
    return _dataConnect.query("GetGroupsForUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetGroupsForUserGroupMembers {
  final GetGroupsForUserGroupMembersGroup group;
  final String role;
  final Timestamp joinedAt;
  GetGroupsForUserGroupMembers.fromJson(dynamic json):
  
  group = GetGroupsForUserGroupMembersGroup.fromJson(json['group']),
  role = nativeFromJson<String>(json['role']),
  joinedAt = Timestamp.fromJson(json['joinedAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetGroupsForUserGroupMembers otherTyped = other as GetGroupsForUserGroupMembers;
    return group == otherTyped.group && 
    role == otherTyped.role && 
    joinedAt == otherTyped.joinedAt;
    
  }
  @override
  int get hashCode => Object.hashAll([group.hashCode, role.hashCode, joinedAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['group'] = group.toJson();
    json['role'] = nativeToJson<String>(role);
    json['joinedAt'] = joinedAt.toJson();
    return json;
  }

  GetGroupsForUserGroupMembers({
    required this.group,
    required this.role,
    required this.joinedAt,
  });
}

@immutable
class GetGroupsForUserGroupMembersGroup {
  final String id;
  final String name;
  final GetGroupsForUserGroupMembersGroupUnit unit;
  final Timestamp createdAt;
  GetGroupsForUserGroupMembersGroup.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  unit = GetGroupsForUserGroupMembersGroupUnit.fromJson(json['unit']),
  createdAt = Timestamp.fromJson(json['createdAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetGroupsForUserGroupMembersGroup otherTyped = other as GetGroupsForUserGroupMembersGroup;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    unit == otherTyped.unit && 
    createdAt == otherTyped.createdAt;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, unit.hashCode, createdAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['unit'] = unit.toJson();
    json['createdAt'] = createdAt.toJson();
    return json;
  }

  GetGroupsForUserGroupMembersGroup({
    required this.id,
    required this.name,
    required this.unit,
    required this.createdAt,
  });
}

@immutable
class GetGroupsForUserGroupMembersGroupUnit {
  final String code;
  final String name;
  GetGroupsForUserGroupMembersGroupUnit.fromJson(dynamic json):
  
  code = nativeFromJson<String>(json['code']),
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetGroupsForUserGroupMembersGroupUnit otherTyped = other as GetGroupsForUserGroupMembersGroupUnit;
    return code == otherTyped.code && 
    name == otherTyped.name;
    
  }
  @override
  int get hashCode => Object.hashAll([code.hashCode, name.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['code'] = nativeToJson<String>(code);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  GetGroupsForUserGroupMembersGroupUnit({
    required this.code,
    required this.name,
  });
}

@immutable
class GetGroupsForUserData {
  final List<GetGroupsForUserGroupMembers> groupMembers;
  GetGroupsForUserData.fromJson(dynamic json):
  
  groupMembers = (json['groupMembers'] as List<dynamic>)
        .map((e) => GetGroupsForUserGroupMembers.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetGroupsForUserData otherTyped = other as GetGroupsForUserData;
    return groupMembers == otherTyped.groupMembers;
    
  }
  @override
  int get hashCode => groupMembers.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['groupMembers'] = groupMembers.map((e) => e.toJson()).toList();
    return json;
  }

  GetGroupsForUserData({
    required this.groupMembers,
  });
}

@immutable
class GetGroupsForUserVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetGroupsForUserVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetGroupsForUserVariables otherTyped = other as GetGroupsForUserVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  GetGroupsForUserVariables({
    required this.userId,
  });
}

