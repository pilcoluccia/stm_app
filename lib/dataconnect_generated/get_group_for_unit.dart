part of 'generated.dart';

class GetGroupForUnitVariablesBuilder {
  String unitId;

  final FirebaseDataConnect _dataConnect;
  GetGroupForUnitVariablesBuilder(this._dataConnect, {required  this.unitId,});
  Deserializer<GetGroupForUnitData> dataDeserializer = (dynamic json)  => GetGroupForUnitData.fromJson(jsonDecode(json));
  Serializer<GetGroupForUnitVariables> varsSerializer = (GetGroupForUnitVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetGroupForUnitData, GetGroupForUnitVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetGroupForUnitData, GetGroupForUnitVariables> ref() {
    GetGroupForUnitVariables vars= GetGroupForUnitVariables(unitId: unitId,);
    return _dataConnect.query("GetGroupForUnit", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetGroupForUnitGroups {
  final String id;
  final String name;
  final GetGroupForUnitGroupsUnit unit;
  final Timestamp createdAt;
  GetGroupForUnitGroups.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  unit = GetGroupForUnitGroupsUnit.fromJson(json['unit']),
  createdAt = Timestamp.fromJson(json['createdAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetGroupForUnitGroups otherTyped = other as GetGroupForUnitGroups;
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

  GetGroupForUnitGroups({
    required this.id,
    required this.name,
    required this.unit,
    required this.createdAt,
  });
}

@immutable
class GetGroupForUnitGroupsUnit {
  final String code;
  final String name;
  GetGroupForUnitGroupsUnit.fromJson(dynamic json):
  
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

    final GetGroupForUnitGroupsUnit otherTyped = other as GetGroupForUnitGroupsUnit;
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

  GetGroupForUnitGroupsUnit({
    required this.code,
    required this.name,
  });
}

@immutable
class GetGroupForUnitData {
  final List<GetGroupForUnitGroups> groups;
  GetGroupForUnitData.fromJson(dynamic json):
  
  groups = (json['groups'] as List<dynamic>)
        .map((e) => GetGroupForUnitGroups.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetGroupForUnitData otherTyped = other as GetGroupForUnitData;
    return groups == otherTyped.groups;
    
  }
  @override
  int get hashCode => groups.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['groups'] = groups.map((e) => e.toJson()).toList();
    return json;
  }

  GetGroupForUnitData({
    required this.groups,
  });
}

@immutable
class GetGroupForUnitVariables {
  final String unitId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetGroupForUnitVariables.fromJson(Map<String, dynamic> json):
  
  unitId = nativeFromJson<String>(json['unitId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetGroupForUnitVariables otherTyped = other as GetGroupForUnitVariables;
    return unitId == otherTyped.unitId;
    
  }
  @override
  int get hashCode => unitId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['unitId'] = nativeToJson<String>(unitId);
    return json;
  }

  GetGroupForUnitVariables({
    required this.unitId,
  });
}

