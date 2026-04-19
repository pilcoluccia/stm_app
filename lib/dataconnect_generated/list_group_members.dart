part of 'generated.dart';

class ListGroupMembersVariablesBuilder {
  String groupId;

  final FirebaseDataConnect _dataConnect;
  ListGroupMembersVariablesBuilder(this._dataConnect, {required  this.groupId,});
  Deserializer<ListGroupMembersData> dataDeserializer = (dynamic json)  => ListGroupMembersData.fromJson(jsonDecode(json));
  Serializer<ListGroupMembersVariables> varsSerializer = (ListGroupMembersVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListGroupMembersData, ListGroupMembersVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListGroupMembersData, ListGroupMembersVariables> ref() {
    ListGroupMembersVariables vars= ListGroupMembersVariables(groupId: groupId,);
    return _dataConnect.query("ListGroupMembers", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListGroupMembersGroupMembers {
  final ListGroupMembersGroupMembersUser user;
  final String role;
  final Timestamp joinedAt;
  ListGroupMembersGroupMembers.fromJson(dynamic json):
  
  user = ListGroupMembersGroupMembersUser.fromJson(json['user']),
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

    final ListGroupMembersGroupMembers otherTyped = other as ListGroupMembersGroupMembers;
    return user == otherTyped.user && 
    role == otherTyped.role && 
    joinedAt == otherTyped.joinedAt;
    
  }
  @override
  int get hashCode => Object.hashAll([user.hashCode, role.hashCode, joinedAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['user'] = user.toJson();
    json['role'] = nativeToJson<String>(role);
    json['joinedAt'] = joinedAt.toJson();
    return json;
  }

  ListGroupMembersGroupMembers({
    required this.user,
    required this.role,
    required this.joinedAt,
  });
}

@immutable
class ListGroupMembersGroupMembersUser {
  final String id;
  final String uid;
  final String name;
  final String? photoUrl;
  ListGroupMembersGroupMembersUser.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  uid = nativeFromJson<String>(json['uid']),
  name = nativeFromJson<String>(json['name']),
  photoUrl = json['photoUrl'] == null ? null : nativeFromJson<String>(json['photoUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListGroupMembersGroupMembersUser otherTyped = other as ListGroupMembersGroupMembersUser;
    return id == otherTyped.id && 
    uid == otherTyped.uid && 
    name == otherTyped.name && 
    photoUrl == otherTyped.photoUrl;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, uid.hashCode, name.hashCode, photoUrl.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['uid'] = nativeToJson<String>(uid);
    json['name'] = nativeToJson<String>(name);
    if (photoUrl != null) {
      json['photoUrl'] = nativeToJson<String?>(photoUrl);
    }
    return json;
  }

  ListGroupMembersGroupMembersUser({
    required this.id,
    required this.uid,
    required this.name,
    this.photoUrl,
  });
}

@immutable
class ListGroupMembersData {
  final List<ListGroupMembersGroupMembers> groupMembers;
  ListGroupMembersData.fromJson(dynamic json):
  
  groupMembers = (json['groupMembers'] as List<dynamic>)
        .map((e) => ListGroupMembersGroupMembers.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListGroupMembersData otherTyped = other as ListGroupMembersData;
    return groupMembers == otherTyped.groupMembers;
    
  }
  @override
  int get hashCode => groupMembers.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['groupMembers'] = groupMembers.map((e) => e.toJson()).toList();
    return json;
  }

  ListGroupMembersData({
    required this.groupMembers,
  });
}

@immutable
class ListGroupMembersVariables {
  final String groupId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListGroupMembersVariables.fromJson(Map<String, dynamic> json):
  
  groupId = nativeFromJson<String>(json['groupId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListGroupMembersVariables otherTyped = other as ListGroupMembersVariables;
    return groupId == otherTyped.groupId;
    
  }
  @override
  int get hashCode => groupId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['groupId'] = nativeToJson<String>(groupId);
    return json;
  }

  ListGroupMembersVariables({
    required this.groupId,
  });
}

