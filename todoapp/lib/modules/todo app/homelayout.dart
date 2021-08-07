import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_conditional_rendering/flutter_conditional_rendering.dart';
import 'package:intl/intl.dart';
import 'package:untitled/shared/components/components.dart';

import 'package:untitled/shared/cubit/cubit.dart';
import 'package:untitled/shared/cubit/states.dart';

class HomeLayout extends StatefulWidget {

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {



  @override
  void initState() {
    super.initState();
  }

  var formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  var scaffoldKey = GlobalKey<ScaffoldState>();





  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context)=> AppCubit()..createDatabase(),
        child: BlocConsumer<AppCubit , AppStates>(
            listener: (context , state){
              if (state is AppInsertDataBaseState){
                Navigator.pop(context);
              }
            },
            builder: (context , state){
              AppCubit cubit=  AppCubit.get(context);
              return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(cubit.titles[cubit.currentIndex]),
                centerTitle: true,
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(cubit.floatIcon),
                onPressed: () {
                  if (!cubit.isBottomSheetShown) {
                    scaffoldKey.currentState!.showBottomSheet(
                          (context) =>
                          Container(
                            color: Colors.grey[100],
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                [
                                  defaultFormField(
                                      label: 'Title',
                                      type: TextInputType.text,
                                      controller: titleController,
                                      prefix: Icons.title_outlined,
                                      validate: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'Please insert the title';
                                        }
                                        return null;
                                      }
                                  ),
                                  defaultFormField(
                                    label: 'Time',

                                    onTap: () {
                                      showTimePicker(context: context,
                                          initialTime: TimeOfDay.now()).then((value) {
                                        timeController.text =
                                            value!.format(context).toString();
                                      });
                                    },

                                    type: TextInputType.datetime,
                                    controller: timeController,
                                    prefix: Icons.watch_later_outlined,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'Please insert the time';
                                      }
                                      return null;
                                    },
                                  ),
                                  defaultFormField(
                                      label: 'Date',
                                      type: TextInputType.datetime,
                                      controller: dateController,
                                      onTap: () {
                                        showDatePicker(context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.parse('2050-12-31'),
                                        ).then((value) {
                                          dateController.text =
                                              DateFormat.yMMMd().format(value!);
                                        }
                                        );
                                      },
                                      prefix: Icons.calendar_today_outlined,
                                      validate: (String? value) {
                                        if (value!.isEmpty) {
                                          return 'Please insert the date';
                                        }
                                        return null;
                                      }
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ).closed.then((value) {

                      cubit.changeBottomSheet(isShow: false, icon: Icons.edit);

                    });
                    cubit.changeBottomSheet(isShow: true, icon: Icons.add);
                  }
                  else {
                    if (formKey.currentState!.validate()) {
                      cubit.insertToDatabase(
                          title: titleController.text,
                          time: timeController.text,
                          date: dateController.text,
                      );
                    }
                  }
                },
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: cubit.currentIndex,
                type: BottomNavigationBarType.fixed,
                items:
                [
                  BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Tasks',),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: 'Done',),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: 'Archived',),
                ],
                onTap: (index) {
                    cubit.changeIndex(index);
                },
              ),
              body: Conditional.single(
                context: context,
                conditionBuilder: (context)=> state is !AppLoadingGetDataBaseState,
                widgetBuilder: (context)=> cubit.screen[cubit.currentIndex],
                fallbackBuilder: (context)=> Center(child: CircularProgressIndicator()),
              ),
            );
            },
        ),
    );
  }






}