part of 'generated.dart';

class CreateGroupVariablesBuilder {
  String name;
  String unitId;

  final FirebaseDataConnect _dataConnect;
  CreateGroupVariablesBuilder(this._dataConnect, {required  this.name,required  this.unitId,});
  Deserializer<CreateGroupData> dataDeserializer = (dynamic json)  => CreateGroupData.fromJson(jsonDecode(json));
  Serializer<CreateGroupVariables> varsSerializer = (CreateGroupVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateGroupData, CreateGroupVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateGroupData, CreateGroupVariables> ref() {
    CreateGroupVariables vars= CreateGroupVariables(name: name,unitId: unitId,);
    return _dataConnect.mutation("CreateGroup", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateGroupGroupInsert {
  final String id;
  CreateGroupGroupInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateGroupGroupInsert otherTyped = other as CreateGroupGroupInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateGroupGroupInsert({
    required this.id,
  });
}

@immutable
class CreateGroupData {
  final CreateGroupGroupInsert group_insert;
  CreateGroupData.fromJson(dynamic json):
  
  group_insert = CreateGroupGroupInsert.fromJson(json['group_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateGroupData otherTyped = other as CreateGroupData;
    return group_insert == otherTyped.group_insert;
    
  }
  @override
  int get hashCode => group_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['group_insert'] = group_insert.toJson();
    return json;
  }

  const CreateGroupData({
    required this.group_insert,
  });
}

@immutable
class CreateGroupVariables {
  final String name;
  final String unitId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateGroupVariables.fromJson(Map<String, dynamic> json):
  
  name = nativeFromJson<String>(json['name']),
  unitId = nativeFromJson<String>(json['unitId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateGroupVariables otherTyped = other as CreateGroupVariables;
    return name == otherTyped.name && 
    unitId == otherTyped.unitId;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, unitId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['unitId'] = nativeToJson<String>(unitId);
    return json;
  }

  const CreateGroupVariables({
    required this.name,
    required this.unitId,
  });
}

