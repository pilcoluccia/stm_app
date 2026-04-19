part of 'generated.dart';

class EnrollInUnitVariablesBuilder {
  String studentId;
  String unitId;

  final FirebaseDataConnect _dataConnect;
  EnrollInUnitVariablesBuilder(this._dataConnect, {required  this.studentId,required  this.unitId,});
  Deserializer<EnrollInUnitData> dataDeserializer = (dynamic json)  => EnrollInUnitData.fromJson(jsonDecode(json));
  Serializer<EnrollInUnitVariables> varsSerializer = (EnrollInUnitVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<EnrollInUnitData, EnrollInUnitVariables>> execute() {
    return ref().execute();
  }

  MutationRef<EnrollInUnitData, EnrollInUnitVariables> ref() {
    EnrollInUnitVariables vars= EnrollInUnitVariables(studentId: studentId,unitId: unitId,);
    return _dataConnect.mutation("EnrollInUnit", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class EnrollInUnitEnrollmentInsert {
  final String studentId;
  final String unitId;
  EnrollInUnitEnrollmentInsert.fromJson(dynamic json):
  
  studentId = nativeFromJson<String>(json['studentId']),
  unitId = nativeFromJson<String>(json['unitId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EnrollInUnitEnrollmentInsert otherTyped = other as EnrollInUnitEnrollmentInsert;
    return studentId == otherTyped.studentId && 
    unitId == otherTyped.unitId;
    
  }
  @override
  int get hashCode => Object.hashAll([studentId.hashCode, unitId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['studentId'] = nativeToJson<String>(studentId);
    json['unitId'] = nativeToJson<String>(unitId);
    return json;
  }

  const EnrollInUnitEnrollmentInsert({
    required this.studentId,
    required this.unitId,
  });
}

@immutable
class EnrollInUnitData {
  final EnrollInUnitEnrollmentInsert enrollment_insert;
  EnrollInUnitData.fromJson(dynamic json):
  
  enrollment_insert = EnrollInUnitEnrollmentInsert.fromJson(json['enrollment_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EnrollInUnitData otherTyped = other as EnrollInUnitData;
    return enrollment_insert == otherTyped.enrollment_insert;
    
  }
  @override
  int get hashCode => enrollment_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['enrollment_insert'] = enrollment_insert.toJson();
    return json;
  }

  const EnrollInUnitData({
    required this.enrollment_insert,
  });
}

@immutable
class EnrollInUnitVariables {
  final String studentId;
  final String unitId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  EnrollInUnitVariables.fromJson(Map<String, dynamic> json):
  
  studentId = nativeFromJson<String>(json['studentId']),
  unitId = nativeFromJson<String>(json['unitId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final EnrollInUnitVariables otherTyped = other as EnrollInUnitVariables;
    return studentId == otherTyped.studentId && 
    unitId == otherTyped.unitId;
    
  }
  @override
  int get hashCode => Object.hashAll([studentId.hashCode, unitId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['studentId'] = nativeToJson<String>(studentId);
    json['unitId'] = nativeToJson<String>(unitId);
    return json;
  }

  const EnrollInUnitVariables({
    required this.studentId,
    required this.unitId,
  });
}

