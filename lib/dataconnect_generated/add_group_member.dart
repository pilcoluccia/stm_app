part of 'generated.dart';

class AddGroupMemberVariablesBuilder {
  String groupId;
  String userId;
  String role;

  final FirebaseDataConnect _dataConnect;
  AddGroupMemberVariablesBuilder(this._dataConnect, {required  this.groupId,required  this.userId,required  this.role,});
  Deserializer<AddGroupMemberData> dataDeserializer = (dynamic json)  => AddGroupMemberData.fromJson(jsonDecode(json));
  Serializer<AddGroupMemberVariables> varsSerializer = (AddGroupMemberVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<AddGroupMemberData, AddGroupMemberVariables>> execute() {
    return ref().execute();
  }

  MutationRef<AddGroupMemberData, AddGroupMemberVariables> ref() {
    AddGroupMemberVariables vars= AddGroupMemberVariables(groupId: groupId,userId: userId,role: role,);
    return _dataConnect.mutation("AddGroupMember", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class AddGroupMemberGroupMemberInsert {
  final String groupId;
  final String userId;
  AddGroupMemberGroupMemberInsert.fromJson(dynamic json):
  
  groupId = nativeFromJson<String>(json['groupId']),
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddGroupMemberGroupMemberInsert otherTyped = other as AddGroupMemberGroupMemberInsert;
    return groupId == otherTyped.groupId && 
    userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => Object.hashAll([groupId.hashCode, userId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['groupId'] = nativeToJson<String>(groupId);
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  const AddGroupMemberGroupMemberInsert({
    required this.groupId,
    required this.userId,
  });
}

@immutable
class AddGroupMemberData {
  final AddGroupMemberGroupMemberInsert groupMember_insert;
  AddGroupMemberData.fromJson(dynamic json):
  
  groupMember_insert = AddGroupMemberGroupMemberInsert.fromJson(json['groupMember_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddGroupMemberData otherTyped = other as AddGroupMemberData;
    return groupMember_insert == otherTyped.groupMember_insert;
    
  }
  @override
  int get hashCode => groupMember_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['groupMember_insert'] = groupMember_insert.toJson();
    return json;
  }

  const AddGroupMemberData({
    required this.groupMember_insert,
  });
}

@immutable
class AddGroupMemberVariables {
  final String groupId;
  final String userId;
  final String role;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  AddGroupMemberVariables.fromJson(Map<String, dynamic> json):
  
  groupId = nativeFromJson<String>(json['groupId']),
  userId = nativeFromJson<String>(json['userId']),
  role = nativeFromJson<String>(json['role']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final AddGroupMemberVariables otherTyped = other as AddGroupMemberVariables;
    return groupId == otherTyped.groupId && 
    userId == otherTyped.userId && 
    role == otherTyped.role;
    
  }
  @override
  int get hashCode => Object.hashAll([groupId.hashCode, userId.hashCode, role.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['groupId'] = nativeToJson<String>(groupId);
    json['userId'] = nativeToJson<String>(userId);
    json['role'] = nativeToJson<String>(role);
    return json;
  }

  const AddGroupMemberVariables({
    required this.groupId,
    required this.userId,
    required this.role,
  });
}

