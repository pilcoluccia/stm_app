part of 'generated.dart';

class ListMessagesVariablesBuilder {
  String groupId;

  final FirebaseDataConnect _dataConnect;
  ListMessagesVariablesBuilder(this._dataConnect, {required  this.groupId,});
  Deserializer<ListMessagesData> dataDeserializer = (dynamic json)  => ListMessagesData.fromJson(jsonDecode(json));
  Serializer<ListMessagesVariables> varsSerializer = (ListMessagesVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListMessagesData, ListMessagesVariables>> execute() {
    return ref().execute();
  }

  QueryRef<ListMessagesData, ListMessagesVariables> ref() {
    ListMessagesVariables vars= ListMessagesVariables(groupId: groupId,);
    return _dataConnect.query("ListMessages", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListMessagesMessages {
  final String id;
  final String text;
  final Timestamp timestamp;
  final ListMessagesMessagesSender sender;
  ListMessagesMessages.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  text = nativeFromJson<String>(json['text']),
  timestamp = Timestamp.fromJson(json['timestamp']),
  sender = ListMessagesMessagesSender.fromJson(json['sender']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMessagesMessages otherTyped = other as ListMessagesMessages;
    return id == otherTyped.id && 
    text == otherTyped.text && 
    timestamp == otherTyped.timestamp && 
    sender == otherTyped.sender;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, text.hashCode, timestamp.hashCode, sender.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['text'] = nativeToJson<String>(text);
    json['timestamp'] = timestamp.toJson();
    json['sender'] = sender.toJson();
    return json;
  }

  ListMessagesMessages({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.sender,
  });
}

@immutable
class ListMessagesMessagesSender {
  final String uid;
  final String name;
  final String? photoUrl;
  ListMessagesMessagesSender.fromJson(dynamic json):
  
  uid = nativeFromJson<String>(json['uid']),
  name = nativeFromJson<String>(json['name']),
  photoUrl = json['photoUrl'] == null ? null : nativeFromJson<String>(json['photoUrl']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMessagesMessagesSender otherTyped = other as ListMessagesMessagesSender;
    return uid == otherTyped.uid && 
    name == otherTyped.name && 
    photoUrl == otherTyped.photoUrl;
    
  }
  @override
  int get hashCode => Object.hashAll([uid.hashCode, name.hashCode, photoUrl.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['uid'] = nativeToJson<String>(uid);
    json['name'] = nativeToJson<String>(name);
    if (photoUrl != null) {
      json['photoUrl'] = nativeToJson<String?>(photoUrl);
    }
    return json;
  }

  ListMessagesMessagesSender({
    required this.uid,
    required this.name,
    this.photoUrl,
  });
}

@immutable
class ListMessagesData {
  final List<ListMessagesMessages> messages;
  ListMessagesData.fromJson(dynamic json):
  
  messages = (json['messages'] as List<dynamic>)
        .map((e) => ListMessagesMessages.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMessagesData otherTyped = other as ListMessagesData;
    return messages == otherTyped.messages;
    
  }
  @override
  int get hashCode => messages.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['messages'] = messages.map((e) => e.toJson()).toList();
    return json;
  }

  ListMessagesData({
    required this.messages,
  });
}

@immutable
class ListMessagesVariables {
  final String groupId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListMessagesVariables.fromJson(Map<String, dynamic> json):
  
  groupId = nativeFromJson<String>(json['groupId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMessagesVariables otherTyped = other as ListMessagesVariables;
    return groupId == otherTyped.groupId;
    
  }
  @override
  int get hashCode => groupId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['groupId'] = nativeToJson<String>(groupId);
    return json;
  }

  ListMessagesVariables({
    required this.groupId,
  });
}

