import 'package:flutter/material.dart';

class TimeStamp extends StatefulWidget {
  @override
  _TimeStampState createState() => _TimeStampState();
}

class _TimeStampState extends State<TimeStamp> {

  String time = "Welcome"; //time display string
  int index = 0, hour = 12, minute = 0;
  String ampm = "AM";
  bool savedTime = false;

  List timestamps = new List<String>();

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

  // set timestamp string to revised timestamp
  // ran by sync() and _navigateEdit()
  void setTime(int h, int m, String a){
    time = h.toString() + ":"
        + (m < 10 ? "0" : "") + "" + m.toString()
        + " " + a;

    // save timestamp to list if not in list
    if(timestamps.indexOf(time) == -1) {
      timestamps.add(time);
      // update index to match the sync'd time
      index = timestamps.length - 1;
    } else{
      index = timestamps.indexOf(time);
    }

    savedTime = true;

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
                child: Text("Save Current Time"),
                onPressed: (){
                  sync();
                  setState(() {});
                }
            ),
            RaisedButton(
                child: Text("Create Timestamp"),
                onPressed: (){
                  _navigateSave(context);
                }
            ),
            RaisedButton(
                child: Text("Timestamp List"),
                onPressed: (){
                  _navigateSelect(context);
                }
            )
          ],
        )
    );
  }

  // Launches TimestampSave screen, awaits result from Navigator.pop
  // result is a list, containing hour, minute, and AM/PM
  _navigateSave(BuildContext context) async {
    List list = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TimestampSave(hour, minute, ampm)
        )
    );

    //extract data from list
    hour = list[0];
    minute = list[1];
    ampm = list[2];

    setTime(hour, minute, ampm);
    setState(() {});
  }

  // Launches TimestampSelect screen, awaits result from Navigator.pop
  // result is an index of the desired timestamp
  _navigateSelect(BuildContext context) async {
    index = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TimestampSelect(timestamps, index)
        )
    );

    // only update if there is a timestamp to choose from
    if(savedTime) {
      time = timestamps[index];
      List<String> s = time.split(new RegExp(":| "));
      hour = int.parse(s[0]);
      minute = int.parse(s[1]);
      ampm = s[2];
      setState(() {});
    }
  }
}

class TimestampSave extends StatefulWidget {

  final int hour;
  final int minute;
  final String ampm;

  const TimestampSave (this.hour, this.minute, this.ampm);

  @override
  _TimestampSaveState createState() => _TimestampSaveState();
}

class _TimestampSaveState extends State<TimestampSave> {

  int _currentHour;
  int _currentMinute;
  int _currentAMPM;

  _setTime(int selection, int i) {
    setState(() {
      switch (selection) {
        case 0:
          _currentHour = i;
          break;
        case 1:
          _currentMinute = i;
          break;
        case 2:
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
        style: (_currentAMPM == null && index == (widget.ampm.compareTo("AM") == 0 ? 0 : 1)) || _currentAMPM == index ? _highlight : _style));

    return Container(
        decoration: new BoxDecoration(
          color: Colors.blue,
        ),

        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Container(
              decoration: _scrollList,
              alignment: Alignment.center,
              height:300,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      child: ListWheelScrollView.useDelegate(
                        // set initial value to last timestamp value
                        controller: FixedExtentScrollController(initialItem: widget.hour - 1),
                        itemExtent: _style.fontSize,
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: hourList,
                        ),
                        squeeze: 0.5,
                        onSelectedItemChanged: (i) => {
                          _setTime(0, i)
                        },
                      ),
                    ),
                    Container(
                      width: 100,
                      child: ListWheelScrollView.useDelegate(
                        // set initial value to last timestamp value
                        controller: FixedExtentScrollController(initialItem: widget.minute),
                        itemExtent: _style.fontSize,
                        childDelegate: ListWheelChildLoopingListDelegate(
                          children: minuteList,
                        ),
                        squeeze: 0.5,
                        onSelectedItemChanged: (i) => {
                          _setTime(1, i)
                        },
                      ),
                    ),
                    Container(
                        width: 100,
                        child: ListWheelScrollView(
                          // set initial value to last timestamp value
                            controller: FixedExtentScrollController(
                                initialItem: widget.ampm.compareTo("AM") == 0 ? 0 : 1
                            ),
                            itemExtent: _style.fontSize,
                            children: ampmList,
                            onSelectedItemChanged: (i) => {
                              _setTime(2, i)
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
                    _currentHour = widget.hour-1;
                  if(_currentMinute == null)
                    _currentMinute = widget.minute;
                  if(_currentAMPM == null)
                    _currentAMPM = widget.ampm.compareTo("AM") == 0 ? 0 : 1;

                  List l = [_currentHour + 1, _currentMinute, (_currentAMPM == 0) ? "AM" : "PM"];

                  Navigator.pop(context, l);
                }
            )
          ],
        )
    );
  }
}


class TimestampSelect extends StatefulWidget {
  final List<String> timestamps;
  final int index;

  const TimestampSelect (this.timestamps, this.index);

  @override
  _TimestampSelectState createState() => _TimestampSelectState();
}

class _TimestampSelectState extends State<TimestampSelect> {

  int _currentTime;
  //https://inducesmile.com/google-flutter/how-to-change-the-background-color-of-selected-listview-in-flutter/
  // change current index for style change
  _setTime(int i){
    setState(() => _currentTime = i);
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

    // generate list for saved timestamps
    // style of text is highlighted to the selected time in the scrollwheel
    // if user has not scrolled, the most recent saved timestamp is highlighted
    List<Widget> times = List.generate(widget.timestamps.length,
      (index) => Text(widget.timestamps[index],
        style: (_currentTime == null && index == widget.index) || _currentTime == index ? _highlight : _style));

    return Container(
      decoration: new BoxDecoration(
        color: Colors.blue,
      ),

      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Container(
            decoration: _scrollList,
            alignment: Alignment.center,
            height:300,
            child: ListWheelScrollView(
              // set initial value to last timestamp value
              controller: FixedExtentScrollController(initialItem: widget.index),
              itemExtent: _style.fontSize,
              children: times,
              squeeze: 0.5,
              onSelectedItemChanged: (i) => {
                _setTime(i)
              },
            )
          ),

          //Pass the selected time back to TimeStamp
          RaisedButton(
              child: Text("Save"),
              onPressed: (){
                if(_currentTime == null)
                  _currentTime = widget.index;
                Navigator.pop(context, _currentTime);
              }
          )
        ],
      )
    );
  }
}
