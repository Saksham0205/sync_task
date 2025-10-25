part of 'groups_cubit.dart';

class GroupsState extends Equatable {
  final List<TaskGroup> groups;

  const GroupsState({this.groups = const []});

  GroupsState copyWith({List<TaskGroup>? groups}) {
    return GroupsState(groups: groups ?? this.groups);
  }

  @override
  List<Object?> get props => [groups];
}
