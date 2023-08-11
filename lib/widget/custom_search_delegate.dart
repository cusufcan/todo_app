import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/data/local_storage.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/model/task_model.dart';
import 'package:todo_app/widget/task_list_item.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<Task> allTasks;

  CustomSearchDelegate({required this.allTasks});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query.isEmpty ? null : query = '';
        },
        icon: const Icon(Icons.clear_outlined),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return GestureDetector(
      onTap: () {
        close(context, null);
      },
      child: const Icon(
        Icons.arrow_back_ios_outlined,
        color: Colors.black,
        size: 24,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Task> filteredList =
        allTasks.where((element) => element.name.toLowerCase().contains(query.toLowerCase())).toList();
    return filteredList.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              var tempTask = filteredList[index];
              return Dismissible(
                background: Container(
                  padding: const EdgeInsets.only(left: 24),
                  alignment: Alignment.centerLeft,
                  color: Colors.red,
                  child: const Icon(Icons.delete_outlined, color: Colors.white),
                ),
                key: Key(tempTask.id),
                onDismissed: (direction) async {
                  filteredList.removeAt(index);
                  await locator<LocalStorage>().deleteTask(task: tempTask);
                },
                direction: DismissDirection.startToEnd,
                child: TaskItem(task: tempTask),
              );
            },
            itemCount: filteredList.length,
          )
        : Center(child: const Text('cannot_find').tr());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
