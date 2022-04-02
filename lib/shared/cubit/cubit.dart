import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  Database? database;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  int currentIndex = 0;

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  void changeIndex(index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarStates());
  }

  int getCounter(List newTasks) {
    return newTasks.length;
  }

  void createDB() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
            'CREATE TABLE Tasks (id INTEGER PRIMARY KEY , title TEXT , date TEXT , time TEXT, status TEXT )')
            .then((value) {
          print('table created');
        }).catchError((onError) {
          print('Error When Creating table ${onError.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDB(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDBState());
    });
  }

  insertToDB({
    required String title,
    required String time,
    required String date,
  }) async {
    await openDatabase('todo.db');
    await database!.transaction((txn) async {
      return txn
          .rawInsert(
        'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")',
      )
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertIntoDBState());
        getDataFromDB(database);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }

  void getDataFromDB(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDBLoadingState());
    database.rawQuery('SELECT *FROM Tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(AppGetDBState());
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async {
    database!.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      getDataFromDB(database);
      emit(AppUpdateDBState());
    });
  }

  void deleteData({
    required int id,
  }) async {
    await database!
        .rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDB(database);
      emit(AppDeleteDBState());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetStates());
  }
}