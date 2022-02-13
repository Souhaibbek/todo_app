import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled/modules/todo%20app/archivedtasks.dart';
import 'package:untitled/modules/todo%20app/donetasks.dart';
import 'package:untitled/modules/todo%20app/newtasks.dart';
import 'package:untitled/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>{

  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<Widget> screen = [NewTasks(), DoneTasks(), ArchivedTasks(),];

  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];


  void changeIndex(index){

    currentIndex=index;
    emit(AppChangeBotNavBarState());
  }

  bool isBottomSheetShown = false;
  IconData floatIcon = Icons.edit;


  void  changeBottomSheet({required bool isShow ,required IconData icon}){

      isBottomSheetShown=isShow;
      floatIcon = icon;
      emit(AppChangeBottomSheetState());
  }


  Database? database;
  List<Map> newTasks=[];
  List<Map> doneTasks=[];
  List<Map> archivedTasks=[];

  void createDatabase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {

        print('database created');
        database
            .execute(
            'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error When Creating Table ${error.toString()}');
        });
      },
      onOpen: (database)
      {
        getDataFromDatabase(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDataBaseState());
    });
  }
  insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) async{
      txn
          .rawInsert(
        'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")',
      )
          .then((value) {
        print('$value inserted successfully');
        emit(AppInsertDataBaseState());

        getDataFromDatabase(database);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });

      return null;
    });
  }

  void getDataFromDatabase(database)
  {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppLoadingGetDataBaseState());

    database.rawQuery('SELECT * FROM tasks').then((value) {

      value.forEach((element)
      {
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archivedTasks.add(element);
      });

      emit(AppGetDataBaseState());
    });
  }

  void updateData({
    required String status,
    required int id,
  }) async
  {
    database!.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value)
    {
      getDataFromDatabase(database);
      emit(AppUpdateDataBaseState());
    });
  }

  void deleteData({
    required int id,
  }) async
  {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id])
        .then((value)
    {
      getDataFromDatabase(database);
      emit(AppDeleteDataBaseState());
    });
  }

}