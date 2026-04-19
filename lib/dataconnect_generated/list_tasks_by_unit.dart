part of 'generated.dart';

class ListTasksByUnitVariablesBuilder {
  String unitId;
  String assignedToId;

  final FirebaseDataConnect _dataConnect;
  ListTasksByUnitVariablesBuilder(this._dataConnect, {required  this.unitId,required  this.assignedToId,});
  Deserializer<ListTasksByUnitData> dataDeserializer = (dynamic json)  => ListTasksByUnitData.fromJson(jsonDecode(json));
  Serializer<ListTasksByUnitVariables> varsSerializer = (ListTasksByUnitVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListTasksByUnitData, ListTasksByUnitVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListTasksByUnitData, ListTasksByUnitVariables> ref() {
    ListTasksByUnitVariables vars= ListTasksByUnitVariables(unitId: unitId,assignedToId: assignedToId,);
    return _dataConnect.query("ListTasksByUnit", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListTasksByUnitTasks {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final Timestamp dueDate;
  final double? estimatedHours;
  final double? completedHours;
  ListTasksByUnitTasks.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  status = nativeFromJson<String>(json['status']),
  priority = nativeFromJson<String>(json['priority']),
  dueDate = Timestamp.fromJson(json['dueDate']),
  estimatedHours = json['estimatedHours'] == null ? null : nativeFromJson<double>(json['estimatedHours']),
  completedHours = json['completedHours'] == null ? null : nativeFromJson<double>(json['completedHours']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListTasksByUnitTasks otherTyped = other as ListTasksByUnitTasks;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    description == otherTyped.description && 
    status == otherTyped.status && 
    priority == otherTyped.priority && 
    dueDate == otherTyped.dueDate && 
    estimatedHours == otherTyped.estimatedHours && 
    completedHours == otherTyped.completedHours;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, description.hashCode, status.hashCode, priority.hashCode, dueDate.hashCode, estimatedHours.hashCode, completedHours.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    json['status'] = nativeToJson<String>(status);
    json['priority'] = nativeToJson<String>(priority);
    json['dueDate'] = dueDate.toJson();
    if (estimatedHours != null) {
      json['estimatedHours'] = nativeToJson<double?>(estimatedHours);
    }
    if (completedHours != null) {
      json['completedHours'] = nativeToJson<double?>(completedHours);
    }
    return json;
  }

  ListTasksByUnitTasks({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.estimatedHours,
    this.completedHours,
  });
}

@immutable
class ListTasksByUnitData {
  final List<ListTasksByUnitTasks> tasks;
  ListTasksByUnitData.fromJson(dynamic json):
  
  tasks = (json['tasks'] as List<dynamic>)
        .map((e) => ListTasksByUnitTasks.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListTasksByUnitData otherTyped = other as ListTasksByUnitData;
    return tasks == otherTyped.tasks;
    
  }
  @override
  int get hashCode => tasks.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['tasks'] = tasks.map((e) => e.toJson()).toList();
    return json;
  }

  ListTasksByUnitData({
    required this.tasks,
  });
}

@immutable
class ListTasksByUnitVariables {
  final String unitId;
  final String assignedToId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListTasksByUnitVariables.fromJson(Map<String, dynamic> json):
  
  unitId = nativeFromJson<String>(json['unitId']),
  assignedToId = nativeFromJson<String>(json['assignedToId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListTasksByUnitVariables otherTyped = other as ListTasksByUnitVariables;
    return unitId == otherTyped.unitId && 
    assignedToId == otherTyped.assignedToId;
    
  }
  @override
  int get hashCode => Object.hashAll([unitId.hashCode, assignedToId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['unitId'] = nativeToJson<String>(unitId);
    json['assignedToId'] = nativeToJson<String>(assignedToId);
    return json;
  }

  ListTasksByUnitVariables({
    required this.unitId,
    required this.assignedToId,
  });
}

