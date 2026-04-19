part of 'generated.dart';

class GetUnitByCodeVariablesBuilder {
  String code;

  final FirebaseDataConnect _dataConnect;
  GetUnitByCodeVariablesBuilder(this._dataConnect, {required  this.code,});
  Deserializer<GetUnitByCodeData> dataDeserializer = (dynamic json)  => GetUnitByCodeData.fromJson(jsonDecode(json));
  Serializer<GetUnitByCodeVariables> varsSerializer = (GetUnitByCodeVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetUnitByCodeData, GetUnitByCodeVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetUnitByCodeData, GetUnitByCodeVariables> ref() {
    GetUnitByCodeVariables vars= GetUnitByCodeVariables(code: code,);
    return _dataConnect.query("GetUnitByCode", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetUnitByCodeUnits {
  final String id;
  final String code;
  final String name;
  final String? description;
  final int credits;
  final String semester;
  final int maxStudents;
  final String lecturerId;
  GetUnitByCodeUnits.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  code = nativeFromJson<String>(json['code']),
  name = nativeFromJson<String>(json['name']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  credits = nativeFromJson<int>(json['credits']),
  semester = nativeFromJson<String>(json['semester']),
  maxStudents = nativeFromJson<int>(json['maxStudents']),
  lecturerId = nativeFromJson<String>(json['lecturerId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUnitByCodeUnits otherTyped = other as GetUnitByCodeUnits;
    return id == otherTyped.id && 
    code == otherTyped.code && 
    name == otherTyped.name && 
    description == otherTyped.description && 
    credits == otherTyped.credits && 
    semester == otherTyped.semester && 
    maxStudents == otherTyped.maxStudents && 
    lecturerId == otherTyped.lecturerId;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, code.hashCode, name.hashCode, description.hashCode, credits.hashCode, semester.hashCode, maxStudents.hashCode, lecturerId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['code'] = nativeToJson<String>(code);
    json['name'] = nativeToJson<String>(name);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    json['credits'] = nativeToJson<int>(credits);
    json['semester'] = nativeToJson<String>(semester);
    json['maxStudents'] = nativeToJson<int>(maxStudents);
    json['lecturerId'] = nativeToJson<String>(lecturerId);
    return json;
  }

  GetUnitByCodeUnits({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.credits,
    required this.semester,
    required this.maxStudents,
    required this.lecturerId,
  });
}

@immutable
class GetUnitByCodeData {
  final List<GetUnitByCodeUnits> units;
  GetUnitByCodeData.fromJson(dynamic json):
  
  units = (json['units'] as List<dynamic>)
        .map((e) => GetUnitByCodeUnits.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUnitByCodeData otherTyped = other as GetUnitByCodeData;
    return units == otherTyped.units;
    
  }
  @override
  int get hashCode => units.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['units'] = units.map((e) => e.toJson()).toList();
    return json;
  }

  GetUnitByCodeData({
    required this.units,
  });
}

@immutable
class GetUnitByCodeVariables {
  final String code;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetUnitByCodeVariables.fromJson(Map<String, dynamic> json):
  
  code = nativeFromJson<String>(json['code']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUnitByCodeVariables otherTyped = other as GetUnitByCodeVariables;
    return code == otherTyped.code;
    
  }
  @override
  int get hashCode => code.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['code'] = nativeToJson<String>(code);
    return json;
  }

  GetUnitByCodeVariables({
    required this.code,
  });
}

