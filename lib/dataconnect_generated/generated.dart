library;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'get_user.dart';

part 'list_all_units.dart';

part 'get_unit_by_code.dart';

part 'create_unit.dart';

part 'list_enrolled_units.dart';

part 'enroll_in_unit.dart';

part 'drop_unit.dart';

part 'list_tasks_by_user.dart';

part 'list_tasks_by_unit.dart';

part 'create_task.dart';

part 'update_task_status.dart';

part 'delete_task.dart';

part 'get_groups_for_user.dart';

part 'get_group_for_unit.dart';

part 'list_group_members.dart';

part 'create_group.dart';

part 'add_group_member.dart';

part 'list_messages.dart';

part 'send_message.dart';

part 'list_notifications.dart';

part 'mark_notification_read.dart';

part 'create_notification.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser ({required String uid, required String email, required String name, required String role, }) {
    return CreateUserVariablesBuilder(dataConnect, uid: uid,email: email,name: name,role: role,);
  }
  
  
  GetUserVariablesBuilder getUser ({required String uid, }) {
    return GetUserVariablesBuilder(dataConnect, uid: uid,);
  }
  
  
  ListAllUnitsVariablesBuilder listAllUnits () {
    return ListAllUnitsVariablesBuilder(dataConnect, );
  }
  
  
  GetUnitByCodeVariablesBuilder getUnitByCode ({required String code, }) {
    return GetUnitByCodeVariablesBuilder(dataConnect, code: code,);
  }
  
  
  CreateUnitVariablesBuilder createUnit ({required String code, required String name, required String lecturerId, required int credits, required String semester, required int maxStudents, }) {
    return CreateUnitVariablesBuilder(dataConnect, code: code,name: name,lecturerId: lecturerId,credits: credits,semester: semester,maxStudents: maxStudents,);
  }
  
  
  ListEnrolledUnitsVariablesBuilder listEnrolledUnits ({required String studentId, }) {
    return ListEnrolledUnitsVariablesBuilder(dataConnect, studentId: studentId,);
  }
  
  
  EnrollInUnitVariablesBuilder enrollInUnit ({required String studentId, required String unitId, }) {
    return EnrollInUnitVariablesBuilder(dataConnect, studentId: studentId,unitId: unitId,);
  }
  
  
  DropUnitVariablesBuilder dropUnit ({required String studentId, required String unitId, }) {
    return DropUnitVariablesBuilder(dataConnect, studentId: studentId,unitId: unitId,);
  }
  
  
  ListTasksByUserVariablesBuilder listTasksByUser ({required String assignedToId, }) {
    return ListTasksByUserVariablesBuilder(dataConnect, assignedToId: assignedToId,);
  }
  
  
  ListTasksByUnitVariablesBuilder listTasksByUnit ({required String unitId, required String assignedToId, }) {
    return ListTasksByUnitVariablesBuilder(dataConnect, unitId: unitId,assignedToId: assignedToId,);
  }
  
  
  CreateTaskVariablesBuilder createTask ({required String title, required String status, required String priority, required Timestamp dueDate, required String assignedToId, required String createdById, required String unitId, }) {
    return CreateTaskVariablesBuilder(dataConnect, title: title,status: status,priority: priority,dueDate: dueDate,assignedToId: assignedToId,createdById: createdById,unitId: unitId,);
  }
  
  
  UpdateTaskStatusVariablesBuilder updateTaskStatus ({required String id, required String status, required double completedHours, }) {
    return UpdateTaskStatusVariablesBuilder(dataConnect, id: id,status: status,completedHours: completedHours,);
  }
  
  
  DeleteTaskVariablesBuilder deleteTask ({required String id, }) {
    return DeleteTaskVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetGroupsForUserVariablesBuilder getGroupsForUser ({required String userId, }) {
    return GetGroupsForUserVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  GetGroupForUnitVariablesBuilder getGroupForUnit ({required String unitId, }) {
    return GetGroupForUnitVariablesBuilder(dataConnect, unitId: unitId,);
  }
  
  
  ListGroupMembersVariablesBuilder listGroupMembers ({required String groupId, }) {
    return ListGroupMembersVariablesBuilder(dataConnect, groupId: groupId,);
  }
  
  
  CreateGroupVariablesBuilder createGroup ({required String name, required String unitId, }) {
    return CreateGroupVariablesBuilder(dataConnect, name: name,unitId: unitId,);
  }
  
  
  AddGroupMemberVariablesBuilder addGroupMember ({required String groupId, required String userId, required String role, }) {
    return AddGroupMemberVariablesBuilder(dataConnect, groupId: groupId,userId: userId,role: role,);
  }
  
  
  ListMessagesVariablesBuilder listMessages ({required String groupId, }) {
    return ListMessagesVariablesBuilder(dataConnect, groupId: groupId,);
  }
  
  
  SendMessageVariablesBuilder sendMessage ({required String groupId, required String senderId, required String text, }) {
    return SendMessageVariablesBuilder(dataConnect, groupId: groupId,senderId: senderId,text: text,);
  }
  
  
  ListNotificationsVariablesBuilder listNotifications ({required String userId, }) {
    return ListNotificationsVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  MarkNotificationReadVariablesBuilder markNotificationRead ({required String id, }) {
    return MarkNotificationReadVariablesBuilder(dataConnect, id: id,);
  }
  
  
  CreateNotificationVariablesBuilder createNotification ({required String userId, required String title, required String body, required String type, }) {
    return CreateNotificationVariablesBuilder(dataConnect, userId: userId,title: title,body: body,type: type,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'us-east4',
    'example',
    'stm-app-cihe-service',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
