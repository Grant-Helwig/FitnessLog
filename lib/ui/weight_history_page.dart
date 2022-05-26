import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../model/weight.dart';
import '../repository/workout_repository.dart';
import '../utils/utils.dart';

class WeightHistory extends StatefulWidget {
  const WeightHistory({Key? key, required this.refreshCallback, required this.initialDateRange}) : super(key: key);
  final Function(DateTimeRange result) refreshCallback;
  final DateTimeRange initialDateRange;

  @override
  State<WeightHistory> createState() => _WeightHistoryState(initialDateRange: this.initialDateRange);
}

class _WeightHistoryState extends State<WeightHistory> {

  WorkoutRepository repo = WorkoutRepository();
  late DateTimeRange initialDateRange;
  _WeightHistoryState({required this.initialDateRange});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DateTimeRange _selectedDateRange = initialDateRange;

  late Future<List<Weight>?> _weightHistory;

  @override
  void initState() {
    super.initState();
    _weightHistory = repo.readAllWeightsByDate(Utils().weekRange());
  }

  void selectDates() async {
    DateTime now = DateTime.now();
    DateTime dateStart = DateTime(now.year - 5, now.month, now.day);
    DateTime dateEnd = DateTime(now.year, now.month, now.day);
    final DateTimeRange? result = await showDateRangePicker(
        context: context,
        firstDate: dateStart,
        lastDate: dateEnd,
        currentDate: now,
        saveText: 'Done'
    );
    if (result != null) {
      setState(() {
        _selectedDateRange = result;
        widget.refreshCallback(result);
        _weightHistory = repo.readAllWeightsByDate(result);
      });
    }
  }

  //update and delete are both on long press
  Future<void> updateOptions(Weight weight) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Divider(),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await addWeightHistoryForm(context, false, weight);
                  },
                ),
                const Divider(),
                TextButton(
                  child: const Text('Delete'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await repo.deleteWeight(weight.id);
                    setState(() {
                      _weightHistory = repo.readAllWeightsByDate(_selectedDateRange);
                    });
                  },
                ),
                const Divider(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addWeightHistoryForm(BuildContext context, bool add, Weight weight) async {
    TextEditingController weightController =
      TextEditingController(text: weight.weight == 0 ? null : weight.weight.toString());

    DateTime myDateTime =
      add ? DateTime.now() : DateTime.parse(weight.date);
    TextEditingController dateController = TextEditingController(
        text: DateFormat('yyyy/MM/dd').format(myDateTime));
    TextEditingController timeController = TextEditingController(
        text: DateFormat('hh:mm a').format(myDateTime));
    return await showDialog(
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setNewState) {
                return AlertDialog(
                  scrollable: true,
                  content: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: weightController,
                          validator: (value){
                            if(value == null || value.isEmpty){
                              return "empty Weight";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                              hintText: "LBS", labelText: "Weight"),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                        ),
                        TextField(
                          controller: dateController,
                          readOnly: true,
                          onTap: () async {
                            DateTime now = DateTime.now();
                            var dateTemp = (await showDatePicker(
                              context: context,
                              initialDate: DateTime.parse(weight.date),
                              firstDate: DateTime(now.year - 5, now.month, now.day),
                              lastDate: DateTime(now.year, now.month, now.day),
                            ));
                            if(dateTemp != null){
                              myDateTime = DateTime(dateTemp.year, dateTemp.month, dateTemp.day, myDateTime.hour, myDateTime.minute);
                              dateController.text =
                                  DateFormat('yyyy/MM/dd').format(myDateTime);
                              setState(() {});
                            }
                          },
                        ),
                        TextField(
                          controller: timeController,
                          readOnly: true,
                          onTap: () async {
                            var timeTemp = (await showTimePicker(
                                context: context,
                                initialTime:TimeOfDay.fromDateTime(DateTime.parse(weight.date))
                            ));
                            if(timeTemp != null){
                              myDateTime = DateTime(myDateTime.year, myDateTime.month, myDateTime.day, timeTemp.hour, timeTemp.minute);
                              timeController.text =
                                  DateFormat('hh:mm a').format(myDateTime);
                              setState(() {});
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          weight.weight = double.parse(
                              weightController.text.isEmpty
                                  ? "0"
                                  : weightController.text);
                          weight.date = myDateTime.toString();

                          if(!add){
                            repo.updateWeight(weight);
                          } else {
                            repo.saveWeight(weight);
                          }
                          setState(() {
                            _weightHistory = repo.readAllWeightsByDate(_selectedDateRange);
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ],

                );
              }
            )
          );
        }
    );
  }
  Widget buildWeightCard(BuildContext context, int index, curWeights) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Card(
        child: ListTile(
          onLongPress: () async {
            return updateOptions(curWeights[index]);
          },
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('${curWeights![index].weight} LBS'),
                    const Spacer(),
                    Text('${DateFormat('yyyy/MM/dd hh:mm a') // hh:mm a
                          .format(DateTime.parse(curWeights![index].date))} ',
                      style: const TextStyle(fontSize: 10),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      body: Container(
        child: Column(
          children: [
            //Date Range Button
            TextButton(
                onPressed: selectDates,
                child: Text(
                  "${DateFormat('yyyy/MM/dd').format(_selectedDateRange.start)} - "
                      "${DateFormat('yyyy/MM/dd').format(_selectedDateRange.end)}",
                  style: const TextStyle(color: Colors.grey, fontSize: 18),
                )),
            const Divider(),

            //build a list of workout history cards
            Expanded(
              child: FutureBuilder<List<dynamic>?>(
                future: _weightHistory,
                builder: (context, projectSnap) {
                  if (projectSnap.hasData) {
                    return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: projectSnap.data!.length,
                        itemBuilder: (BuildContext context, int index) =>
                            buildWeightCard(
                                context,
                                index,
                                projectSnap.data!));
                  } else {
                    return const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'No History',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Weight weight = Weight();
          weight.weight = 0;
          weight.date = DateTime.now().toString();
          await addWeightHistoryForm(context, true, weight);
        },
        tooltip: 'Add Workout',
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
      ),
    );
  }
}
