part of 'generated.dart';

class UpdateTaskStatusVariablesBuilder {
  String id;
  String status;
  double completedHours;

  final FirebaseDataConnect _dataConnect;
  UpdateTaskStatusVariablesBuilder(this._dataConnect, {required  this.id,required  this.status,required  this.completedHours,});
  Deserializer<UpdateTaskStatusData> dataDeserializer = (dynamic json)  => UpdateTaskStatusData.fromJson(jsonDecode(json));
  Serializer<UpdateTaskStatusVariables> varsSerializer = (UpdateTaskStatusVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateTaskStatusData, UpdateTaskStatusVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateTaskStatusData, UpdateTaskStatusVariables> ref() {
    UpdateTaskStatusVariables vars= UpdateTaskStatusVariables(id: id,status: status,completedHours: completedHours,);
    return _dataConnect.mutation("UpdateTaskStatus", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateTaskStatusTaskUpdate {
  final String id;
  UpdateTaskStatusTaskUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateTaskStatusTaskUpdate otherTyped = other as UpdateTaskStatusTaskUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const UpdateTaskStatusTaskUpdate({
    required this.id,
  });
}

@immutable
class UpdateTaskStatusData {
  final UpdateTaskStatusTaskUpdate? task_update;
  UpdateTaskStatusData.fromJson(dynamic json):
  
  task_update = json['task_update'] == null ? null : UpdateTaskStatusTaskUpdate.fromJson(json['task_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateTaskStatusData otherTyped = other as UpdateTaskStatusData;
    return task_update == otherTyped.task_update;
    
  }
  @override
  int get hashCode => task_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (task_update != null) {
      json['task_update'] = task_update!.toJson();
    }
    return json;
  }

  const UpdateTaskStatusData({
    this.task_update,
  });
}

@immutable
class UpdateTaskStatusVariables {
  final String id;
  final String status;
  final double completedHours;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateTaskStatusVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  status = nativeFromJson<String>(json['status']),
  completedHours = nativeFromJson<double>(json['completedHours']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateTaskStatusVariables otherTyped = other as UpdateTaskStatusVariables;
    return id == otherTyped.id && 
    status == otherTyped.status && 
    completedHours == otherTyped.completedHours;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, status.hashCode, completedHours.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['status'] = nativeToJson<String>(status);
    json['completedHours'] = nativeToJson<double>(completedHours);
    return json;
  }

  const UpdateTaskStatusVariables({
    required this.id,
    required this.status,
    required this.completedHours,
  });
}

