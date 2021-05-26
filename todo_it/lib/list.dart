import 'package:flutter/material.dart';

// Every component in Flutter is a widget, even the whole app itself
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(title: 'Todo List', home: new TodoList());
  }
}

class TodoList extends StatefulWidget {
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<String> _todoItems = [];
  final ScrollController _scrollController = ScrollController();
  bool _needScroll = false;

  // This will be called each time the + button is pressed
  void _addTodoItem(String task) {
    // Only add the task if the user actually entered something
    if (task.length > 0) {
      setState(() => _todoItems.add(task));
    }
  }

  // Build the whole list of todo items
  Widget _buildTodoList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        // itemBuilder will be automatically be called as many times as it takes for the
        // list to fill up its available space, which is most likely more than the
        // number of todo items we have. So, we need to check the index is OK.
        if (index < _todoItems.length) {
          return _buildTodoItem(_todoItems[index], index);
        }
      },
    );
  }

  // Build a single todo item
  Widget _buildTodoItem(String todoText, int index) {
    return new ListTile(
      title: new Text(todoText),
      onTap: () => _promptRemoveTodoItem(index),
    );
  }

  // Scrolls to the bottom of the list
  _scrollToEnd() async {
    if (_needScroll) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  @override
  build(BuildContext context) {
    if (_needScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
    return new Scaffold(
      appBar: new AppBar(title: new Text('Todo List')),
      body: _buildTodoList(),
      floatingActionButton: new FloatingActionButton(
        onPressed: _pushAddTodoScreen,
        tooltip: 'Add task',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _pushAddTodoScreen() {
    //Flag to Flutter that a scroll is needed
    _needScroll = true;
    // Push this page onto the stack
    Navigator.of(context).push(
        // MaterialPageRoute will automatically animate the screen entry, as well
        // as adding a back button to close it
        new MaterialPageRoute(builder: (context) {
      return new Scaffold(
          appBar: new AppBar(
            title: new Text('Add a new task'),
          ),
          body: new TextField(
            autofocus: true,
            onSubmitted: (val) {
              _addTodoItem(val);
              Navigator.pop(context);
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToEnd());
            },
            decoration: new InputDecoration(
                hintText: 'Enter something to do...',
                contentPadding: const EdgeInsets.all(16.0)),
          ));
    }));
  }

  void _removeTodoItem(int index) {
    setState(() => _todoItems.removeAt(index));
  }

  void _promptRemoveTodoItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Mark "${_todoItems[index]}" as done?'),
              actions: <Widget>[
                new TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text('CANCEL'),
                ),
                new TextButton(
                  onPressed: () {
                    _removeTodoItem(index);
                    Navigator.of(context).pop();
                  },
                  child: new Text('MARK AS DONE'),
                )
              ]);
        });
  }
}
