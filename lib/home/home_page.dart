import 'package:demoapp/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('Todo List Page'),
            actions: [
              IconButton(
                onPressed: () {
                  controller.findAnimalCount();
                },
                icon: Icon(Icons.animation),
              ),
            ],
          ),
          body:
              controller.allTodoData.isEmpty
                  ? Center(child: Text("No Data Found!"))
                  : ListView.builder(
                    itemCount: controller.allTodoData.length,
                    itemBuilder: (context, index) {
                      final item = controller.allTodoData[index];
                      DateTime dateTime = DateTime.parse(item.time);
                      String formatted = DateFormat(
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(dateTime);
                      print(formatted);
                      return GestureDetector(
                        onTap: () {
                          controller.showBottomSheet(
                            context,
                            existingItem: item,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            height: 80,
                            width: Get.width,
                            decoration: BoxDecoration(
                              color: Colors.brown[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.title.capitalizeFirst!,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        item.description.capitalizeFirst!,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(formatted),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.redAccent[400],
                                  ),
                                  onPressed: () async {
                                    await controller.deleteItem(item.id!);
                                    controller.refreshItemList();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

          floatingActionButton: FloatingActionButton(
            tooltip: "Create Todo",
            onPressed: () => controller.showBottomSheet(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
