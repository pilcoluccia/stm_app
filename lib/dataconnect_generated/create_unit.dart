part of 'generated.dart';

class CreateUnitVariablesBuilder {
  String code;
  String name;
  String lecturerId;
  int credits;
  String semester;
  int maxStudents;
  final Optional<String> _description = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreateUnitVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }

  CreateUnitVariablesBuilder(this._dataConnect, {required  this.code,required  this.name,required  this.lecturerId,required  this.credits,required  this.semester,required  this.maxStudents,});
  Deserializer<CreateUnitData> dataDeserializer = (dynamic json)  => CreateUnitData.fromJson(jsonDecode(json));
  Serializer<CreateUnitVariables> varsSerializer = (CreateUnitVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateUnitData, CreateUnitVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateUnitData, CreateUnitVariables> ref() {
    CreateUnitVariables vars= CreateUnitVariables(code: code,name: name,lecturerId: lecturerId,credits: credits,semester: semester,maxStudents: maxStudents,description: _description,);
    return _dataConnect.mutation("CreateUnit", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateUnitUnitInsert {
  final String id;
  CreateUnitUnitInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUnitUnitInsert otherTyped = other as CreateUnitUnitInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateUnitUnitInsert({
    required this.id,
  });
}

@immutable
class CreateUnitData {
  final CreateUnitUnitInsert unit_insert;
  CreateUnitData.fromJson(dynamic json):
  
  unit_insert = CreateUnitUnitInsert.fromJson(json['unit_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUnitData otherTyped = other as CreateUnitData;
    return unit_insert == otherTyped.unit_insert;
    
  }
  @override
  int get hashCode => unit_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['unit_insert'] = unit_insert.toJson();
    return json;
  }

  const CreateUnitData({
    required this.unit_insert,
  });
}

@immutable
class CreateUnitVariables {
  final String code;
  final String name;
  final String lecturerId;
  final int credits;
  final String semester;
  final int maxStudents;
  late final Optional<String>description;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateUnitVariables.fromJson(Map<String, dynamic> json):
  
  code = nativeFromJson<String>(json['code']),
  name = nativeFromJson<String>(json['name']),
  lecturerId = nativeFromJson<String>(json['lecturerId']),
  credits = nativeFromJson<int>(json['credits']),
  semester = nativeFromJson<String>(json['semester']),
  maxStudents = nativeFromJson<int>(json['maxStudents']) {
  
  
  
  
  
  
  
  
    description = Optional.optional(nativeFromJson, nativeToJson);
    description.value = json['description'] == null ? null : nativeFromJson<String>(json['description']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateUnitVariables otherTyped = other as CreateUnitVariables;
    return code == otherTyped.code && 
    name == otherTyped.name && 
    lecturerId == otherTyped.lecturerId && 
    credits == otherTyped.credits && 
    semester == otherTyped.semester && 
    maxStudents == otherTyped.maxStudents && 
    description == otherTyped.description;
    
  }
  @override
  int get hashCode => Object.hashAll([code.hashCode, name.hashCode, lecturerId.hashCode, credits.hashCode, semester.hashCode, maxStudents.hashCode, description.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['code'] = nativeToJson<String>(code);
    json['name'] = nativeToJson<String>(name);
    json['lecturerId'] = nativeToJson<String>(lecturerId);
    json['credits'] = nativeToJson<int>(credits);
    json['semester'] = nativeToJson<String>(semester);
    json['maxStudents'] = nativeToJson<int>(maxStudents);
    if(description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    return json;
  }

  const CreateUnitVariables({
    required this.code,
    required this.name,
    required this.lecturerId,
    required this.credits,
    required this.semester,
    required this.maxStudents,
    required this.description,
  });
}

