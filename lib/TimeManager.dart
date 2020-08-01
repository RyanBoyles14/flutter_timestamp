import 'package:flutter/material.dart';

class TimeStamp extends StatefulWidget {
  @override
  _TimeStampState createState() => _TimeStampState();
}

class _TimeStampState extends State<TimeStamp> {

  int hour = 0;
  int minute = 0;
  String ampm = "";
  String time = "";

  _TimeStampState(){
    sync(); //get timestamp on startup
  }

  // get the current timestamp
  void sync(){
      hour = getHour();

      //convert from military time
      if(hour == 0)
        hour = 12;
      else if(hour > 12)
        hour -= 12;

      minute = getMinute();
      ampm = getAMPM();

      // time format: 00:00 XM
      time = hour.toString() + ":"
          + (minute < 10 ? "0" : "") + "" + minute.toString()
          + " " + ampm;
  }

  void setText(bool isSync){
    //update timestamp w/ current time
    setState(() {
      if(isSync)
        sync();
    });
  }

  int getHour(){
    return new DateTime.now().hour;
  }

  int getMinute(){
    return new DateTime.now().minute;
  }

  String getAMPM(){
    if(getHour() < 12)
      return "AM";
    else
      return "PM";
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        decoration: new BoxDecoration(
          color: Colors.blue,
        ),

        child: new Column(
          children: <Widget>[
            Text(
              "$time",

              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),

            RaisedButton(
                child: Text("Sync"),
                onPressed: (){
                  setText(true);
                }
            ),

            RaisedButton(
                child: Text("Edit"),
                onPressed: (){
                  _navigateEdit(context);
                }
            )
          ],
        )
    );
  }

  // Launches TimeEdit screen, awaits result from Navigator.pop
  _navigateEdit(BuildContext context) async {
    time = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TimeEdit()
        )
    );

    setText(false);
  }
}

class TimeEdit extends StatefulWidget {
  @override
  _TimeEditState createState() => _TimeEditState();
}

class _TimeEditState extends State<TimeEdit> {

  @override
  Widget build(BuildContext context) {

    final _style = Theme.of(context).textTheme.headline3;

    return Container(
      decoration: new BoxDecoration(
        color: Colors.blue,
      ),

      child: new Column(
        children:[
          Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300,
                  maxWidth: 100
                ),
                child: ListWheelScrollView.useDelegate(
                  itemExtent: _style.fontSize,
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List<Widget>.generate(12, (index) => Text("${index + 1}", style: _style)),
                  ),
                  squeeze: 0.5,
                )
              ),
              ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 300,
                      maxWidth: 100
                  ),
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: _style.fontSize,
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: List<Widget>.generate(60, (index) => Text("${index}", style: _style)),
                    ),
                    squeeze: 0.5,
                  )
              ),
              ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 300,
                      maxWidth: 100
                  ),
                  child: ListWheelScrollView(
                    itemExtent: _style.fontSize,
                    children: [Text("AM", style: _style), Text("PM",  style: _style)]
                  )
              ),
          ]),

          RaisedButton(
              child: Text("Save"),
              onPressed: (){
                Navigator.pop(context, "test");
              }
          )
        ],
      )
    );
  }
}
