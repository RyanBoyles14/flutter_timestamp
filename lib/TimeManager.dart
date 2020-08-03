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

  List timestamps = new List<int>();

  _TimeStampState(){
    sync(); //get timestamp on startup
  }

  // get the current timestamp
  void sync(){
      hour = getHour();
      minute = getMinute();
      ampm = getAMPM();

      // timestamp to save is in military format, so only one list needed
      int t = hour * 100 + minute;
      // save timestamp to list if not in list
      if(timestamps.indexOf(t) == -1) {
        timestamps.add(t);
        timestamps.sort((a, b) => a.compareTo(b));
      }

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
          mainAxisAlignment: MainAxisAlignment.center,
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
            builder: (context) => TimestampSelect(hour, minute, ampm, timestamps)
        )
    );

    hour = l[0];
    minute = l[1];
    ampm = l[2] == 0 ? "AM" : "PM";

    // time format: 00:00 XM
    setTime(hour, minute, ampm);

    updateText(false);
  }
}

class TimestampSelect extends StatefulWidget {
  final int hour;
  final int minute;
  final String ampm;
  final List<int> timestamps;

  const TimestampSelect (this.hour, this.minute, this.ampm, this.timestamps);

  @override
  _TimestampSelectState createState() => _TimestampSelectState();
}

class _TimestampSelectState extends State<TimestampSelect> {

  int _currentHour;
  int _currentMinute;
  int _currentAMPM;

  //https://inducesmile.com/google-flutter/how-to-change-the-background-color-of-selected-listview-in-flutter/
  // change current index for style change
  _setTime(String val, int i){
    setState(() {
      switch(val){
        case "Hour":
          _currentHour = i;
          break;
        case "Min":
          _currentMinute = i;
          break;
        case "AMPM":
          _currentAMPM = i;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    final _style = TextStyle(
      color: Colors.white,
      decoration: TextDecoration.none,
      fontSize: 36
    );

    final _highlight = TextStyle(
      color: Colors.lightBlue,
      decoration: TextDecoration.none,
      fontSize: 36
    );

    final _scrollList = new BoxDecoration(
        color: Colors.white54
    );

    // generate lists for hours, minutes, AM/PM
    // style of text is highlighted to the selected time in the scrollwheel
    // if user has not scrolled, the most recent saved timestamp is highlighted
    List<Widget> hourList = List<Widget>.generate(12, (index) => Text("${index + 1}",
        style: (_currentHour == null && index == widget.hour - 1) || _currentHour == index ? _highlight : _style));
    List<Widget> minuteList = List<Widget>.generate(60, (index) => Text("$index",
        style: (_currentMinute == null && index == widget.minute) || _currentMinute == index ? _highlight : _style));
    List<Widget> ampmList = List<Widget>.generate(2, (index) => Text(index == 0 ? "AM" : "PM",
        style: (_currentAMPM == null && index == (widget.ampm.compareTo("AM") == 0 ? 0 : 1)) ||_currentAMPM == index ? _highlight : _style));

    return Container(
      decoration: new BoxDecoration(
        color: Colors.blue,
      ),

      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Container(
            decoration: _scrollList,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 300,
                  child: ListWheelScrollView.useDelegate(
                    // set initial value to last timestamp value
                    controller: FixedExtentScrollController(initialItem: widget.hour - 1),
                    itemExtent: _style.fontSize,
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: hourList,
                    ),
                    squeeze: 0.5,
                    onSelectedItemChanged: (i) => {
                      _setTime("Hour", i)
                    },
                  ),
                ),
                Container(
                  width: 100,
                  height: 300,
                  child: ListWheelScrollView.useDelegate(
                    // set initial value to last timestamp value
                    controller: FixedExtentScrollController(initialItem: widget.minute),
                    itemExtent: _style.fontSize,
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: minuteList,
                    ),
                    squeeze: 0.5,
                    onSelectedItemChanged: (i) => {
                      _setTime("Min", i)
                    },
                  ),
                ),
                Container(
                  width: 100,
                  height: 300,
                  child: ListWheelScrollView(
                    // set initial value to last timestamp value
                    controller: FixedExtentScrollController(
                        initialItem: widget.ampm.compareTo("AMP") == 0 ? 0 : 1
                    ),
                    itemExtent: _style.fontSize,
                    children: ampmList,
                    onSelectedItemChanged: (i) => {
                      _setTime("AMPM", i)
                    },
                    squeeze: 0.5
                  )
                ),
            ]),
          ),

          //Pass the selected time back to TimeStamp
          RaisedButton(
              child: Text("Save"),
              onPressed: (){
                // if user did not scroll these value, set them to the last updated timestamp values
                if(_currentHour == null)
                  _currentHour = widget.hour;
                if(_currentMinute == null)
                  _currentMinute = widget.minute;
                if(_currentAMPM == null)
                  _currentAMPM = widget.ampm.compareTo("AM") == 0 ? 0 : 1;
                List l = [_currentHour, _currentMinute, _currentAMPM];
                Navigator.pop(context, l);
              }
          )
        ],
      )
    );
  }
}
