part of 'generated.dart';

class CreateTaskVariablesBuilder {
  String title;
  final Optional<String> _description = Optional.optional(nativeFromJson, nativeToJson);
  String status;
  String priority;
  Timestamp dueDate;
  final Optional<double> _estimatedHours = Optional.optional(nativeFromJson, nativeToJson);
  String assignedToId;
  String createdById;
  String unitId;

  final FirebaseDataConnect _dataConnect;  CreateTaskVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }
  CreateTaskVariablesBuilder estimatedHours(double? t) {
   _estimatedHours.value = t;
   return this;
  }

  CreateTaskVariablesBuilder(this._dataConnect, {required  this.title,required  this.status,required  this.priority,required  this.dueDate,required  this.assignedToId,required  this.createdById,required  this.unitId,});
  Deserializer<CreateTaskData> dataDeserializer = (dynamic json)  => CreateTaskData.fromJson(jsonDecode(json));
  Serializer<CreateTaskVariables> varsSerializer = (CreateTaskVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateTaskData, CreateTaskVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateTaskData, CreateTaskVariables> ref() {
    CreateTaskVariables vars= CreateTaskVariables(title: title,description: _description,status: status,priority: priority,dueDate: dueDate,estimatedHours: _estimatedHours,assignedToId: assignedToId,createdById: createdById,unitId: unitId,);
    return _dataConnect.mutation("CreateTask", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateTaskTaskInsert {
  final String id;
  CreateTaskTaskInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateTaskTaskInsert otherTyped = other as CreateTaskTaskInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateTaskTaskInsert({
    required this.id,
  });
}

@immutable
class CreateTaskData {
  final CreateTaskTaskInsert task_insert;
  CreateTaskData.fromJson(dynamic json):
  
  task_insert = CreateTaskTaskInsert.fromJson(json['task_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateTaskData otherTyped = other as CreateTaskData;
    return task_insert == otherTyped.task_insert;
    
  }
  @override
  int get hashCode => task_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['task_insert'] = task_insert.toJson();
    return json;
  }

  const CreateTaskData({
    required this.task_insert,
  });
}

@immutable
class CreateTaskVariables {
  final String title;
  late final Optional<String>description;
  final String status;
  final String priority;
  final Timestamp dueDate;
  late final Optional<double>estimatedHours;
  final String assignedToId;
  final String createdById;
  final String unitId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateTaskVariables.fromJson(Map<String, dynamic> json):
  
  title = nativeFromJson<String>(json['title']),
  status = nativeFromJson<String>(json['status']),
  priority = nativeFromJson<String>(json['priority']),
  dueDate = Timestamp.fromJson(json['dueDate']),
  assignedToId = nativeFromJson<String>(json['assignedToId']),
  createdById = nativeFromJson<String>(json['createdById']),
  unitId = nativeFromJson<String>(json['unitId']) {
  
  
  
    description = Optional.optional(nativeFromJson, nativeToJson);
    description.value = json['description'] == null ? null : nativeFromJson<String>(json['description']);
  
  
  
  
  
    estimatedHours = Optional.optional(nativeFromJson, nativeToJson);
    estimatedHours.value = json['estimatedHours'] == null ? null : nativeFromJson<double>(json['estimatedHours']);
  
  
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateTaskVariables otherTyped = other as CreateTaskVariables;
    return title == otherTyped.title && 
    description == otherTyped.description && 
    status == otherTyped.status && 
    priority == otherTyped.priority && 
    dueDate == otherTyped.dueDate && 
    estimatedHours == otherTyped.estimatedHours && 
    assignedToId == otherTyped.assignedToId && 
    createdById == otherTyped.createdById && 
    unitId == otherTyped.unitId;
    
  }
  @override
  int get hashCode => Object.hashAll([title.hashCode, description.hashCode, status.hashCode, priority.hashCode, dueDate.hashCode, estimatedHours.hashCode, assignedToId.hashCode, createdById.hashCode, unitId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['title'] = nativeToJson<String>(title);
    if(description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    json['status'] = nativeToJson<String>(status);
    json['priority'] = nativeToJson<String>(priority);
    json['dueDate'] = dueDate.toJson();
    if(estimatedHours.state == OptionalState.set) {
      json['estimatedHours'] = estimatedHours.toJson();
    }
    json['assignedToId'] = nativeToJson<String>(assignedToId);
    json['createdById'] = nativeToJson<String>(createdById);
    json['unitId'] = nativeToJson<String>(unitId);
    return json;
  }

  const CreateTaskVariables({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.estimatedHours,
    required this.assignedToId,
    required this.createdById,
    required this.unitId,
  });
}

