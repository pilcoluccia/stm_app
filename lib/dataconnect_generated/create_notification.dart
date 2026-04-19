part of 'generated.dart';

class CreateNotificationVariablesBuilder {
  String userId;
  String title;
  String body;
  String type;

  final FirebaseDataConnect _dataConnect;
  CreateNotificationVariablesBuilder(this._dataConnect, {required  this.userId,required  this.title,required  this.body,required  this.type,});
  Deserializer<CreateNotificationData> dataDeserializer = (dynamic json)  => CreateNotificationData.fromJson(jsonDecode(json));
  Serializer<CreateNotificationVariables> varsSerializer = (CreateNotificationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateNotificationData, CreateNotificationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateNotificationData, CreateNotificationVariables> ref() {
    CreateNotificationVariables vars= CreateNotificationVariables(userId: userId,title: title,body: body,type: type,);
    return _dataConnect.mutation("CreateNotification", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateNotificationNotificationInsert {
  final String id;
  CreateNotificationNotificationInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateNotificationNotificationInsert otherTyped = other as CreateNotificationNotificationInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateNotificationNotificationInsert({
    required this.id,
  });
}

@immutable
class CreateNotificationData {
  final CreateNotificationNotificationInsert notification_insert;
  CreateNotificationData.fromJson(dynamic json):
  
  notification_insert = CreateNotificationNotificationInsert.fromJson(json['notification_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateNotificationData otherTyped = other as CreateNotificationData;
    return notification_insert == otherTyped.notification_insert;
    
  }
  @override
  int get hashCode => notification_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['notification_insert'] = notification_insert.toJson();
    return json;
  }

  const CreateNotificationData({
    required this.notification_insert,
  });
}

@immutable
class CreateNotificationVariables {
  final String userId;
  final String title;
  final String body;
  final String type;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateNotificationVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  title = nativeFromJson<String>(json['title']),
  body = nativeFromJson<String>(json['body']),
  type = nativeFromJson<String>(json['type']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateNotificationVariables otherTyped = other as CreateNotificationVariables;
    return userId == otherTyped.userId && 
    title == otherTyped.title && 
    body == otherTyped.body && 
    type == otherTyped.type;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, title.hashCode, body.hashCode, type.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['title'] = nativeToJson<String>(title);
    json['body'] = nativeToJson<String>(body);
    json['type'] = nativeToJson<String>(type);
    return json;
  }

  const CreateNotificationVariables({
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
  });
}

