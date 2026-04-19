part of 'generated.dart';

class ListTasksByUserVariablesBuilder {
  String assignedToId;

  final FirebaseDataConnect _dataConnect;
  ListTasksByUserVariablesBuilder(this._dataConnect, {required  this.assignedToId,});
  Deserializer<ListTasksByUserData> dataDeserializer = (dynamic json)  => ListTasksByUserData.fromJson(jsonDecode(json));
  Serializer<ListTasksByUserVariables> varsSerializer = (ListTasksByUserVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListTasksByUserData, ListTasksByUserVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListTasksByUserData, ListTasksByUserVariables> ref() {
    ListTasksByUserVariables vars= ListTasksByUserVariables(assignedToId: assignedToId,);
    return _dataConnect.query("ListTasksByUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListTasksByUserTasks {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final Timestamp dueDate;
  final double? estimatedHours;
  final double? completedHours;
  final Timestamp createdAt;
  final ListTasksByUserTasksUnit unit;
  final ListTasksByUserTasksCreatedBy createdBy;
  ListTasksByUserTasks.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  status = nativeFromJson<String>(json['status']),
  priority = nativeFromJson<String>(json['priority']),
  dueDate = Timestamp.fromJson(json['dueDate']),
  estimatedHours = json['estimatedHours'] == null ? null : nativeFromJson<double>(json['estimatedHours']),
  completedHours = json['completedHours'] == null ? null : nativeFromJson<double>(json['completedHours']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  unit = ListTasksByUserTasksUnit.fromJson(json['unit']),
  createdBy = ListTasksByUserTasksCreatedBy.fromJson(json['createdBy']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListTasksByUserTasks otherTyped = other as ListTasksByUserTasks;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    description == otherTyped.description && 
    status == otherTyped.status && 
    priority == otherTyped.priority && 
    dueDate == otherTyped.dueDate && 
    estimatedHours == otherTyped.estimatedHours && 
    completedHours == otherTyped.completedHours && 
    createdAt == otherTyped.createdAt && 
    unit == otherTyped.unit && 
    createdBy == otherTyped.createdBy;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, description.hashCode, status.hashCode, priority.hashCode, dueDate.hashCode, estimatedHours.hashCode, completedHours.hashCode, createdAt.hashCode, unit.hashCode, createdBy.hashCode]);
  

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
    json['createdAt'] = createdAt.toJson();
    json['unit'] = unit.toJson();
    json['createdBy'] = createdBy.toJson();
    return json;
  }

  ListTasksByUserTasks({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.estimatedHours,
    this.completedHours,
    required this.createdAt,
    required this.unit,
    required this.createdBy,
  });
}

@immutable
class ListTasksByUserTasksUnit {
  final String code;
  final String name;
  ListTasksByUserTasksUnit.fromJson(dynamic json):
  
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

    final ListTasksByUserTasksUnit otherTyped = other as ListTasksByUserTasksUnit;
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

  ListTasksByUserTasksUnit({
    required this.code,
    required this.name,
  });
}

@immutable
class ListTasksByUserTasksCreatedBy {
  final String name;
  ListTasksByUserTasksCreatedBy.fromJson(dynamic json):
  
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListTasksByUserTasksCreatedBy otherTyped = other as ListTasksByUserTasksCreatedBy;
    return name == otherTyped.name;
    
  }
  @override
  int get hashCode => name.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  ListTasksByUserTasksCreatedBy({
    required this.name,
  });
}

@immutable
class ListTasksByUserData {
  final List<ListTasksByUserTasks> tasks;
  ListTasksByUserData.fromJson(dynamic json):
  
  tasks = (json['tasks'] as List<dynamic>)
        .map((e) => ListTasksByUserTasks.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListTasksByUserData otherTyped = other as ListTasksByUserData;
    return tasks == otherTyped.tasks;
    
  }
  @override
  int get hashCode => tasks.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['tasks'] = tasks.map((e) => e.toJson()).toList();
    return json;
  }

  ListTasksByUserData({
    required this.tasks,
  });
}

@immutable
class ListTasksByUserVariables {
  final String assignedToId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListTasksByUserVariables.fromJson(Map<String, dynamic> json):
  
  assignedToId = nativeFromJson<String>(json['assignedToId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListTasksByUserVariables otherTyped = other as ListTasksByUserVariables;
    return assignedToId == otherTyped.assignedToId;
    
  }
  @override
  int get hashCode => assignedToId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['assignedToId'] = nativeToJson<String>(assignedToId);
    return json;
  }

  ListTasksByUserVariables({
    required this.assignedToId,
  });
}

