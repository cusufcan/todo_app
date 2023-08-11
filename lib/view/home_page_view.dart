import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';
import 'package:todo_app/data/local_storage.dart';
import 'package:todo_app/widget/custom_search_delegate.dart';

import '../main.dart';
import '../model/task_model.dart';
import '../widget/task_list_item.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  late LocalStorage _localStorage;
  late List<Task> _allTasks;

  @override
  void initState() {
    super.initState();
    _localStorage = locator<LocalStorage>();
    _allTasks = <Task>[];
    _getAllTasksFromDb();
  }

  Future<void> _getAllTasksFromDb() async {
    _allTasks = await _localStorage.getAllTask();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _showAddTaskBottomSheet();
          },
          child: const Text(
            'title',
            style: TextStyle(color: Colors.black),
          ).tr(),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              _showSearchPage();
            },
            icon: const Icon(Icons.search_outlined),
          ),
          IconButton(
            onPressed: () {
              _showAddTaskBottomSheet();
            },
            icon: const Icon(Icons.add_outlined),
          ),
        ],
      ),
      body: _allTasks.isNotEmpty
          ? ListView.builder(
              itemBuilder: (context, index) {
                var tempTask = _allTasks[index];
                return Dismissible(
                  background: Container(
                    padding: const EdgeInsets.only(left: 24),
                    alignment: Alignment.centerLeft,
                    color: Colors.red,
                    child: const Icon(Icons.delete_outlined, color: Colors.white),
                  ),
                  key: Key(tempTask.id),
                  onDismissed: (direction) {
                    _allTasks.removeAt(index);
                    _localStorage.deleteTask(task: tempTask);
                    setState(() {});
                  },
                  direction: DismissDirection.startToEnd,
                  child: TaskItem(task: tempTask),
                );
              },
              itemCount: _allTasks.length,
            )
          : Center(child: const Text('empty_task_list').tr()),
    );
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: TextField(
              autofocus: true,
              style: const TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'add_task'.tr(),
                border: InputBorder.none,
              ),
              onSubmitted: (value) async {
                Navigator.of(context).pop();
                if (value.length > 3) {
                  final DateTime? result = await TimePicker.show<DateTime>(
                    context: context,
                    sheet: TimePickerSheet(
                      initialDateTime: DateTime.now(),
                      hourInterval: 1,
                      minuteInterval: 1,
                      sheetTitle: '',
                      minuteTitle: 'hour'.tr(),
                      hourTitle: 'minute'.tr(),
                      saveButtonText: 'save'.tr(),
                    ),
                  );
                  if (result != null) {
                    var tempTask = Task.create(name: value, createdAt: result);
                    _allTasks.insert(0, tempTask);
                    _localStorage.addTask(task: tempTask);
                  }
                  setState(() {});
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSearchPage() async {
    await showSearch(context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    _getAllTasksFromDb();
  }
}
