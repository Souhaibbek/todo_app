import 'package:flutter/material.dart';
import 'package:flutter_conditional_rendering/conditional.dart';
import 'package:untitled/shared/cubit/cubit.dart';


Widget defaultFormField(
  {
    required String  label,
    required TextInputType type,
    required TextEditingController controller,
    required IconData prefix ,
    required validate,
    onTap,
    bool isPass = false,
    IconData? suffix,
    suffixPressed,
    bool isEnable=true,

  }
    ){
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    child: TextFormField(
      controller: controller,
      validator: validate,
      keyboardType: type,
      obscureText: isPass,
      onTap: onTap,
      enabled: isEnable,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefix),
        suffixIcon: suffix!= null ? IconButton(onPressed: suffixPressed, icon: Icon(suffix),) : null,
        border: OutlineInputBorder(),
      ),
    ),
  );
}


Widget buildTaskItem(Map model, context) => Dismissible(

  key: Key(model['id'].toString()),
  child:Padding(

    padding: const EdgeInsets.all(20.0),

    child: Row(

      children: [

        CircleAvatar(

          radius: 40.0,

          child: Text(

            '${model['time']}',

          ),

        ),

        SizedBox(

          width: 20.0,

        ),

        Expanded(

          child: Column(

            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                '${model['title']}',

                style: TextStyle(

                  fontSize: 18.0,

                  fontWeight: FontWeight.bold,

                ),

              ),

              Text(

                '${model['date']}',

                style: TextStyle(

                  color: Colors.grey,

                ),

              ),

            ],

          ),

        ),

        SizedBox(

          width: 20.0,

        ),

        IconButton(onPressed: ()

        {

          AppCubit.get(context).updateData(

            status: 'done',

            id: model['id'],

          );

        },

          icon: Icon(Icons.check_box,color: Colors.green,),),

        IconButton(onPressed: ()

        {

          AppCubit.get(context).updateData(

            status: 'archived',

            id: model['id'],

          );

        },

          icon: Icon(Icons.archive_rounded,color: Colors.black45,),),



      ],

    ),

  ),
  onDismissed: (direction){
    AppCubit.get(context).deleteData(id: model['id'],);
  },
);


Widget tasksBuilder({
  required List<Map> tasks,
  required BuildContext context,

})=>Conditional.single(
  context: context,
  conditionBuilder:  (context)=> tasks.length >0 ,
  widgetBuilder: (context){return ListView.separated(
    itemBuilder: (context , index)=> buildTaskItem(tasks[index],context),
    separatorBuilder: (context, index) => Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20.0,
      ),
      child: Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey[300],
      ),
    ),
    itemCount: tasks.length,
  );},
  fallbackBuilder: (context){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu,size: 100.0,color: Colors.grey,),
          SizedBox(height: 15.0,),
          Text('No Tasks Yet ! Please Add Some Tasks',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0,color: Colors.grey),),
        ],
      ),
    );
  },
);