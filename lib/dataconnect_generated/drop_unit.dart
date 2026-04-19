part of 'generated.dart';

class DropUnitVariablesBuilder {
  String studentId;
  String unitId;

  final FirebaseDataConnect _dataConnect;
  DropUnitVariablesBuilder(this._dataConnect, {required  this.studentId,required  this.unitId,});
  Deserializer<DropUnitData> dataDeserializer = (dynamic json)  => DropUnitData.fromJson(jsonDecode(json));
  Serializer<DropUnitVariables> varsSerializer = (DropUnitVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DropUnitData, DropUnitVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DropUnitData, DropUnitVariables> ref() {
    DropUnitVariables vars= DropUnitVariables(studentId: studentId,unitId: unitId,);
    return _dataConnect.mutation("DropUnit", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DropUnitData {
  final int enrollment_deleteMany;
  DropUnitData.fromJson(dynamic json):
  
  enrollment_deleteMany = nativeFromJson<int>(json['enrollment_deleteMany']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DropUnitData otherTyped = other as DropUnitData;
    return enrollment_deleteMany == otherTyped.enrollment_deleteMany;
    
  }
  @override
  int get hashCode => enrollment_deleteMany.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['enrollment_deleteMany'] = nativeToJson<int>(enrollment_deleteMany);
    return json;
  }

  const DropUnitData({
    required this.enrollment_deleteMany,
  });
}

@immutable
class DropUnitVariables {
  final String studentId;
  final String unitId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DropUnitVariables.fromJson(Map<String, dynamic> json):
  
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

    final DropUnitVariables otherTyped = other as DropUnitVariables;
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

  const DropUnitVariables({
    required this.studentId,
    required this.unitId,
  });
}

