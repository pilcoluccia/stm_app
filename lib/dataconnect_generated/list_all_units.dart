part of 'generated.dart';

class ListAllUnitsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListAllUnitsVariablesBuilder(this._dataConnect, );
  Deserializer<ListAllUnitsData> dataDeserializer = (dynamic json)  => ListAllUnitsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListAllUnitsData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListAllUnitsData, void> ref() {
    
    return _dataConnect.query("ListAllUnits", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListAllUnitsUnits {
  final String id;
  final String code;
  final String name;
  final String? description;
  final int credits;
  final String semester;
  final int maxStudents;
  final String lecturerId;
  ListAllUnitsUnits.fromJson(dynamic json):
  
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

    final ListAllUnitsUnits otherTyped = other as ListAllUnitsUnits;
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

  ListAllUnitsUnits({
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
class ListAllUnitsData {
  final List<ListAllUnitsUnits> units;
  ListAllUnitsData.fromJson(dynamic json):
  
  units = (json['units'] as List<dynamic>)
        .map((e) => ListAllUnitsUnits.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListAllUnitsData otherTyped = other as ListAllUnitsData;
    return units == otherTyped.units;
    
  }
  @override
  int get hashCode => units.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['units'] = units.map((e) => e.toJson()).toList();
    return json;
  }

  ListAllUnitsData({
    required this.units,
  });
}

