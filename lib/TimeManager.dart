import 'package:flutter/material.dart';

class TimeStamp extends StatefulWidget {
  @override
  _TimeStampState createState() => _TimeStampState();
}

class _TimeStampState extends State<TimeStamp> {

  int hour = 0;
  int minute = 0;
  String ampm = "";
  String time = ""; //time display string

  _TimeStampState(){
    sync(); //get timestamp on startup
  }

  // get the current timestamp
  void sync(){
      hour = getHour();
      minute = getMinute();
      ampm = getAMPM();

      //convert from military time
      if(hour == 0)
        hour = 12;
      else if(hour > 12)
        hour -= 12;

      // time format: 00:00 XM
      setTime(hour, minute, ampm);
  }

  void updateText(bool isSync){
    //update text w/ current timestamp
    setState(() {
      if(isSync) // only run sync() when Sync button is pressed
        sync();

    });
  }

  // set timestamp string to revised timestamp
  // ran by sync() and _navigateEdit()
  void setTime(int h, int m, String a){
    time = h.toString() + ":"
        + (m < 10 ? "0" : "") + "" + m.toString()
        + " " + a;
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
            Text( //Timestamp text
              "$time",

              style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),

            RaisedButton(
                child: Text("Sync"),
                onPressed: (){
                  updateText(true);
                }
            ),

            RaisedButton(
                child: Text("Timestamps"),
                onPressed: (){
                  _navigateEdit(context);
                }
            )
          ],
        )
    );
  }

  // Launches TimeEdit screen, awaits result from Navigator.pop
  // result is a list containing the hour, minute, and AM/PM
  _navigateEdit(BuildContext context) async {
    List l = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TimestampSelect(hour, minute)
        )
    );

    hour = l[0];
    minute = l[1];
    ampm = l[2];

    // time format: 00:00 XM
    setTime(hour, minute, ampm);

    updateText(false);
  }
}

class TimestampSelect extends StatefulWidget {
  final int hour;
  final int minute;

  const TimestampSelect (this.hour, this.minute);

  @override
  _TimestampSelectState createState() => _TimestampSelectState();
}

class _TimestampSelectState extends State<TimestampSelect> {

  @override
  Widget build(BuildContext context) {

    int finalHour = widget.hour;
    int finalMinute = widget.minute;
    String ampm = "AM";
    final _style = Theme.of(context).textTheme.headline3;

    List<Widget> hourList = List<Widget>.generate(12, (index) => Text((index + widget.hour) % 12 == 0 ? "12" : "${(index + widget.hour) % 12} ", style: _style));
    List<Widget> minuteList = List<Widget>.generate(60, (index) => Text("${(index + widget.minute) % 60}", style: _style));
    List<Widget> ampmList =  [Text("AM", style: _style), Text("PM",  style: _style)];

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
                    children: hourList,
                  ),
                  squeeze: 0.5,
                  onSelectedItemChanged: (i) => {
                    finalHour = (widget.hour + i) % 12,
                    if(finalHour == 0)
                      finalHour = 12,
                  },
                ),
              ),
              ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 300,
                      maxWidth: 100
                  ),
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: _style.fontSize,
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: minuteList,
                    ),
                    squeeze: 0.5,
                    onSelectedItemChanged: (i) => {
                      finalMinute = (widget.minute + i) % 60
                    },
                  )
              ),
              ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 300,
                      maxWidth: 100
                  ),
                  child: ListWheelScrollView(
                    itemExtent: _style.fontSize,
                    children: ampmList,
                    onSelectedItemChanged: (i) => {
                      ampm = (i == 0) ? "AM" : "PM"
                    },
                    squeeze: 0.5
                  )
              ),
          ]),

          //Pass the selected time back to TimeStamp
          RaisedButton(
              child: Text("Save"),
              onPressed: (){
                List l = [finalHour, finalMinute, ampm];
                Navigator.pop(context, l);
              }
          )
        ],
      )
    );
  }
}
