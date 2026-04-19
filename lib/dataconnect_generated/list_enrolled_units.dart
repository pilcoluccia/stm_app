part of 'generated.dart';

class ListEnrolledUnitsVariablesBuilder {
  String studentId;

  final FirebaseDataConnect _dataConnect;
  ListEnrolledUnitsVariablesBuilder(this._dataConnect, {required  this.studentId,});
  Deserializer<ListEnrolledUnitsData> dataDeserializer = (dynamic json)  => ListEnrolledUnitsData.fromJson(jsonDecode(json));
  Serializer<ListEnrolledUnitsVariables> varsSerializer = (ListEnrolledUnitsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListEnrolledUnitsData, ListEnrolledUnitsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListEnrolledUnitsData, ListEnrolledUnitsVariables> ref() {
    ListEnrolledUnitsVariables vars= ListEnrolledUnitsVariables(studentId: studentId,);
    return _dataConnect.query("ListEnrolledUnits", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListEnrolledUnitsEnrollments {
  final ListEnrolledUnitsEnrollmentsUnit unit;
  final Timestamp enrolledAt;
  final String status;
  ListEnrolledUnitsEnrollments.fromJson(dynamic json):
  
  unit = ListEnrolledUnitsEnrollmentsUnit.fromJson(json['unit']),
  enrolledAt = Timestamp.fromJson(json['enrolledAt']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListEnrolledUnitsEnrollments otherTyped = other as ListEnrolledUnitsEnrollments;
    return unit == otherTyped.unit && 
    enrolledAt == otherTyped.enrolledAt && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([unit.hashCode, enrolledAt.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['unit'] = unit.toJson();
    json['enrolledAt'] = enrolledAt.toJson();
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  ListEnrolledUnitsEnrollments({
    required this.unit,
    required this.enrolledAt,
    required this.status,
  });
}

@immutable
class ListEnrolledUnitsEnrollmentsUnit {
  final String id;
  final String code;
  final String name;
  final String? description;
  final int credits;
  final String semester;
  final String lecturerId;
  ListEnrolledUnitsEnrollmentsUnit.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  code = nativeFromJson<String>(json['code']),
  name = nativeFromJson<String>(json['name']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  credits = nativeFromJson<int>(json['credits']),
  semester = nativeFromJson<String>(json['semester']),
  lecturerId = nativeFromJson<String>(json['lecturerId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListEnrolledUnitsEnrollmentsUnit otherTyped = other as ListEnrolledUnitsEnrollmentsUnit;
    return id == otherTyped.id && 
    code == otherTyped.code && 
    name == otherTyped.name && 
    description == otherTyped.description && 
    credits == otherTyped.credits && 
    semester == otherTyped.semester && 
    lecturerId == otherTyped.lecturerId;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, code.hashCode, name.hashCode, description.hashCode, credits.hashCode, semester.hashCode, lecturerId.hashCode]);
  

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
    json['lecturerId'] = nativeToJson<String>(lecturerId);
    return json;
  }

  ListEnrolledUnitsEnrollmentsUnit({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.credits,
    required this.semester,
    required this.lecturerId,
  });
}

@immutable
class ListEnrolledUnitsData {
  final List<ListEnrolledUnitsEnrollments> enrollments;
  ListEnrolledUnitsData.fromJson(dynamic json):
  
  enrollments = (json['enrollments'] as List<dynamic>)
        .map((e) => ListEnrolledUnitsEnrollments.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListEnrolledUnitsData otherTyped = other as ListEnrolledUnitsData;
    return enrollments == otherTyped.enrollments;
    
  }
  @override
  int get hashCode => enrollments.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['enrollments'] = enrollments.map((e) => e.toJson()).toList();
    return json;
  }

  ListEnrolledUnitsData({
    required this.enrollments,
  });
}

@immutable
class ListEnrolledUnitsVariables {
  final String studentId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListEnrolledUnitsVariables.fromJson(Map<String, dynamic> json):
  
  studentId = nativeFromJson<String>(json['studentId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListEnrolledUnitsVariables otherTyped = other as ListEnrolledUnitsVariables;
    return studentId == otherTyped.studentId;
    
  }
  @override
  int get hashCode => studentId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['studentId'] = nativeToJson<String>(studentId);
    return json;
  }

  ListEnrolledUnitsVariables({
    required this.studentId,
  });
}

