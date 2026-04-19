part of 'generated.dart';

class ListNotificationsVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  ListNotificationsVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<ListNotificationsData> dataDeserializer = (dynamic json)  => ListNotificationsData.fromJson(jsonDecode(json));
  Serializer<ListNotificationsVariables> varsSerializer = (ListNotificationsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListNotificationsData, ListNotificationsVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListNotificationsData, ListNotificationsVariables> ref() {
    ListNotificationsVariables vars= ListNotificationsVariables(userId: userId,);
    return _dataConnect.query("ListNotifications", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListNotificationsNotifications {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final Timestamp createdAt;
  final ListNotificationsNotificationsTask? task;
  final ListNotificationsNotificationsGroup? group;
  ListNotificationsNotifications.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']),
  body = nativeFromJson<String>(json['body']),
  type = nativeFromJson<String>(json['type']),
  read = nativeFromJson<bool>(json['read']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  task = json['task'] == null ? null : ListNotificationsNotificationsTask.fromJson(json['task']),
  group = json['group'] == null ? null : ListNotificationsNotificationsGroup.fromJson(json['group']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListNotificationsNotifications otherTyped = other as ListNotificationsNotifications;
    return id == otherTyped.id && 
    title == otherTyped.title && 
    body == otherTyped.body && 
    type == otherTyped.type && 
    read == otherTyped.read && 
    createdAt == otherTyped.createdAt && 
    task == otherTyped.task && 
    group == otherTyped.group;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode, body.hashCode, type.hashCode, read.hashCode, createdAt.hashCode, task.hashCode, group.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    json['body'] = nativeToJson<String>(body);
    json['type'] = nativeToJson<String>(type);
    json['read'] = nativeToJson<bool>(read);
    json['createdAt'] = createdAt.toJson();
    if (task != null) {
      json['task'] = task!.toJson();
    }
    if (group != null) {
      json['group'] = group!.toJson();
    }
    return json;
  }

  ListNotificationsNotifications({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.createdAt,
    this.task,
    this.group,
  });
}

@immutable
class ListNotificationsNotificationsTask {
  final String id;
  final String title;
  ListNotificationsNotificationsTask.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  title = nativeFromJson<String>(json['title']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListNotificationsNotificationsTask otherTyped = other as ListNotificationsNotificationsTask;
    return id == otherTyped.id && 
    title == otherTyped.title;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, title.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['title'] = nativeToJson<String>(title);
    return json;
  }

  ListNotificationsNotificationsTask({
    required this.id,
    required this.title,
  });
}

@immutable
class ListNotificationsNotificationsGroup {
  final String id;
  final String name;
  ListNotificationsNotificationsGroup.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListNotificationsNotificationsGroup otherTyped = other as ListNotificationsNotificationsGroup;
    return id == otherTyped.id && 
    name == otherTyped.name;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    return json;
  }

  ListNotificationsNotificationsGroup({
    required this.id,
    required this.name,
  });
}

@immutable
class ListNotificationsData {
  final List<ListNotificationsNotifications> notifications;
  ListNotificationsData.fromJson(dynamic json):
  
  notifications = (json['notifications'] as List<dynamic>)
        .map((e) => ListNotificationsNotifications.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListNotificationsData otherTyped = other as ListNotificationsData;
    return notifications == otherTyped.notifications;
    
  }
  @override
  int get hashCode => notifications.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['notifications'] = notifications.map((e) => e.toJson()).toList();
    return json;
  }

  ListNotificationsData({
    required this.notifications,
  });
}

@immutable
class ListNotificationsVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListNotificationsVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListNotificationsVariables otherTyped = other as ListNotificationsVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  ListNotificationsVariables({
    required this.userId,
  });
}

