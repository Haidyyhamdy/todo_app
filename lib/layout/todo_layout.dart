import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDB(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, state) {
          if (state is AppInsertIntoDBState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, Object? state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.teal[400],
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: ConditionalBuilder(
              condition: State is! AppGetDBLoadingState,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.teal[400],
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit.insertToDB(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Created One Task.'),
                      ),
                    );
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet((context) => Container(
                    color: Colors.grey[100],
                    padding: EdgeInsets.all(20.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          defaultFormField(
                              controller: titleController,
                              type: TextInputType.text,
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'Title must not be empty';
                                }
                              },
                              label: ' Task Title',
                              prefix: Icons.title),
                          SizedBox(height: 15),
                          defaultFormField(
                              controller: timeController,
                              onTap: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) {
                                  timeController.text =
                                      value!.format(context);
                                });
                              },
                              type: TextInputType.datetime,
                              validate: (value) {
                                if (value!.isEmpty) {
                                  return 'Time must not be empty';
                                }
                              },
                              label: 'Task Time',
                              prefix: Icons.watch_later_outlined),
                          SizedBox(
                            height: 15,
                          ),
                          defaultFormField(
                              controller: dateController,
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate:
                                  DateTime.parse('2022-01-30'),
                                ).then((value) {
                                  dateController.text =
                                      DateFormat.yMMMd().format(value!);
                                });
                              },
                              type: TextInputType.datetime,
                              validate: (value) {
                                if (value!.isEmpty) {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   const SnackBar( content:Text('Date must not be empty'),
                                  //   ),
                                  // );
                                  return 'Date must not be empty';
                                }
                              },
                              label: 'Task Date',
                              prefix: Icons.calendar_today),
                        ],
                      ),
                    ),
                  ))
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(
                        isShow: false, icon: Icons.edit);
                    titleController.clear();
                    timeController.clear();
                    dateController.clear();
                  });
                  cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedLabelStyle: TextStyle(
                color: Colors.white,
              ),
              elevation: 150,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.teal[400],
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                    color: Colors.white,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
