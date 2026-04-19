part of 'generated.dart';

class SendMessageVariablesBuilder {
  String groupId;
  String senderId;
  String text;

  final FirebaseDataConnect _dataConnect;
  SendMessageVariablesBuilder(this._dataConnect, {required  this.groupId,required  this.senderId,required  this.text,});
  Deserializer<SendMessageData> dataDeserializer = (dynamic json)  => SendMessageData.fromJson(jsonDecode(json));
  Serializer<SendMessageVariables> varsSerializer = (SendMessageVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<SendMessageData, SendMessageVariables>> execute() {
    return ref().execute();
  }

  MutationRef<SendMessageData, SendMessageVariables> ref() {
    SendMessageVariables vars= SendMessageVariables(groupId: groupId,senderId: senderId,text: text,);
    return _dataConnect.mutation("SendMessage", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class SendMessageMessageInsert {
  final String id;
  SendMessageMessageInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SendMessageMessageInsert otherTyped = other as SendMessageMessageInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const SendMessageMessageInsert({
    required this.id,
  });
}

@immutable
class SendMessageData {
  final SendMessageMessageInsert message_insert;
  SendMessageData.fromJson(dynamic json):
  
  message_insert = SendMessageMessageInsert.fromJson(json['message_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SendMessageData otherTyped = other as SendMessageData;
    return message_insert == otherTyped.message_insert;
    
  }
  @override
  int get hashCode => message_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['message_insert'] = message_insert.toJson();
    return json;
  }

  const SendMessageData({
    required this.message_insert,
  });
}

@immutable
class SendMessageVariables {
  final String groupId;
  final String senderId;
  final String text;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  SendMessageVariables.fromJson(Map<String, dynamic> json):
  
  groupId = nativeFromJson<String>(json['groupId']),
  senderId = nativeFromJson<String>(json['senderId']),
  text = nativeFromJson<String>(json['text']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SendMessageVariables otherTyped = other as SendMessageVariables;
    return groupId == otherTyped.groupId && 
    senderId == otherTyped.senderId && 
    text == otherTyped.text;
    
  }
  @override
  int get hashCode => Object.hashAll([groupId.hashCode, senderId.hashCode, text.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['groupId'] = nativeToJson<String>(groupId);
    json['senderId'] = nativeToJson<String>(senderId);
    json['text'] = nativeToJson<String>(text);
    return json;
  }

  const SendMessageVariables({
    required this.groupId,
    required this.senderId,
    required this.text,
  });
}

