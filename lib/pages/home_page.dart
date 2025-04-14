import 'package:expense_tracker_app/components/expense_summary.dart';
import 'package:expense_tracker_app/components/expense_tile.dart';
import 'package:expense_tracker_app/data/expense_data.dart';
import 'package:expense_tracker_app/models/expense_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controllers

  final newExpenseNameController = TextEditingController();
  final newExpenseDollarController = TextEditingController ();
  final newExpenseCentsController = TextEditingController ();

  @override
  void initState() {
    super.initState();

    // prepare data on startup
    Provider.of<ExpenseData>(context, listen: false).prepareData();
  }

  // add new expense
  void addNewExpense() {
    showDialog(
      context: context,
     builder: (context) => AlertDialog(
      title: Text( 'Add new expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // expense name
            TextField(
              controller: newExpenseNameController,
              decoration: const InputDecoration(
                hintText: "Expense name",
              ),
            ),
        
            Row(
              children: [
              // dollars
                Expanded(
                  child: TextField(
                    controller: newExpenseDollarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Dollars",
                    ),
                  ),
                ),
        
              // cents
              Expanded(
                  child: TextField(
                    controller: newExpenseCentsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Cents",
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      actions: [
        // save button
        MaterialButton(
          onPressed: save,
          child: Text('Save'),
          ),

        // cancel button
        MaterialButton(
          onPressed: cancel,
          child: Text('Cancel'),
          ),  
      ],
     ),
    );
  }

  // delete expense
  void deleteExpense(ExpenseItem expense) {
    Provider.of<ExpenseData>(context, listen: false).deleteExpense(expense);
  }

  // edit expense
  void editExpense(ExpenseItem expense) {
  // Pre-fill controllers
  List<String> amountParts = expense.amount.split('.');
  newExpenseNameController.text = expense.name;
  newExpenseDollarController.text = amountParts[0];
  newExpenseCentsController.text = amountParts.length > 1 ? amountParts[1] : '00';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Edit expense'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newExpenseNameController,
              decoration: const InputDecoration(hintText: "Expense name"),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: newExpenseDollarController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Dollars"),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: newExpenseCentsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: "Cents"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            String updatedAmount =
                '${newExpenseDollarController.text}.${newExpenseCentsController.text}';

            ExpenseItem updatedExpense = ExpenseItem(
              name: newExpenseNameController.text,
              amount: updatedAmount,
              dateTime: expense.dateTime, // keep original date
            );

            Provider.of<ExpenseData>(context, listen: false)
              ..deleteExpense(expense)
              ..addNewExpense(updatedExpense);

            Navigator.pop(context);
            clear();
          },
          child: Text('Save'),
        ),
        MaterialButton(
          onPressed: () {
            Navigator.pop(context);
            clear();
          },
          child: Text('Cancel'),
        ),
      ],
    ),
  );
}

  // save
  void save() {
    // only save expense if all fields are filled
    if (newExpenseNameController.text.isNotEmpty &&
        newExpenseDollarController.text.isNotEmpty &&
        newExpenseCentsController.text.isNotEmpty) {
    // put dollars and cents together
    String amount = 
        '${newExpenseDollarController.text}.${newExpenseCentsController.text}';

    // create expense item
    ExpenseItem newExpense = ExpenseItem(
      name: newExpenseNameController.text,
      amount: amount,
      dateTime: DateTime.now()
      );
      // add the new expense
    Provider.of<ExpenseData>(context, listen: false)
        .addNewExpense(newExpense);
  }

    Navigator.pop(context);
    clear();
  }

  // cancel
  void cancel () {
    Navigator.pop(context);
    clear();
  }

  // clear controllers
  void clear() {
    newExpenseNameController.clear();
    newExpenseDollarController.clear();
    newExpenseCentsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.grey[300],
        floatingActionButton: FloatingActionButton(
          onPressed: addNewExpense,
          backgroundColor: Colors.black,
          child:const  Icon(Icons.add),
        ),
        body: ListView(children: [
          // weekly summary
          ExpenseSummary(startOfWeek: value.startOfWeekDate()),

          // expense list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: value.getAllExpenseList().length,
            itemBuilder: (context, index) => ExpenseTile(
              name: value.getAllExpenseList()[index].name,
              amount: value.getAllExpenseList()[index].amount,
              dateTime: value.getAllExpenseList()[index].dateTime,
              deleteTapped: (p0) => 
              deleteExpense(value.getAllExpenseList()[index]),
              editTapped: (context) => editExpense(value.getAllExpenseList()[index]),
            ),
          )
        ],),
      ),
    );  
  }
}