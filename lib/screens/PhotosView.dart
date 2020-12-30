import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import '../engine.dart';
class GoneTolist extends StatefulWidget {
  GoneTolist({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GoneTolistState createState() => _GoneTolistState();
}

class _GoneTolistState extends State<GoneTolist> {
  bool ontapselect = false;
  TextEditingController txt =new TextEditingController();
  String appbar_text="Gone To";

  @override
  void dispose() {
    txt.dispose();
    super.dispose();
  }

  @override
  void initState() {
    onStart();
  }

  void onStart() async {
    await Provider.of<searchengine>(context, listen: false)
        .GetGoneTo(); //check for any changes in the database"to be able to add funcnalioty"

  }

  //if(topics.length==0){Provider.of<searchengine>(context, listen: false).getTopics();topics=Provider.of<searchengine>(context, listen: false).topics;} //push to next screen


  @override
  Widget build(BuildContext context) {
    Provider
        .of<searchengine>(context, listen: false)
        .screenwidth = MediaQuery
        .of(context)
        .size
        .width;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.search,
              size:30,
              color: Theme.of(context).brightness==Brightness.light?Theme.of(context).buttonColor:Colors.white,
            ),
            backgroundColor: Theme.of(context).brightness==Brightness.light?Colors.white:Colors.black,
            onPressed: (){

              showModalBottomSheet(context: context,isScrollControlled: true, builder: (ctx) {
                return Container(
                  padding:
                  EdgeInsets.only(bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    child: TextFormField(
                      autofocus: true,
                      controller: txt,
                      onFieldSubmitted:(value) {Navigator.pop(context);
                      setState(() {
                        appbar_text="country: "+value;
                      });
                      if(value==""){Provider.of<searchengine>(context, listen: false).ReadDB();
                      setState(() {
                        appbar_text="Gone To";
                      });}},
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(
                          fontSize: 15,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        border: InputBorder.none,
                        hintText: 'Enter Country',
                        hintStyle: TextStyle(fontSize: 24,
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color,
                        ),
                        labelText: 'Country',
                        labelStyle: TextStyle(fontSize: 18,
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color,
                        ),

                      ),
                      style: TextStyle(fontSize: 24,
                          color: Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              .color
                      ),

                      onChanged: (value) {
                        setState(() {
                          appbar_text="country: "+value;
                        });
                        Provider.of<searchengine>(context, listen: false)
                            .getspecificcountry_gone_too(value);
                      },
                    ),
                  ),
                );
              });
            }
        ),
      backgroundColor: Colors.grey[900],
      appBar: Provider.of<searchengine>(context, listen: false).SelectedExist(
          Provider
              .of<searchengine>(context, listen: false)
              .DB_Mountains_Gone_To) == true ? SelectedAppBar(context) : NormalAppBar(),

      body: Consumer<searchengine>(
          builder: (context, searchengine data, child) {
            return data.DB_Mountains_Gone_To.length != 0
                ?TopicCards(data, context)
                :appbar_text!="Gone To"?SearchNotFound():SeeMountains();
          }
      ),
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.

    );
  }

  StaggeredGridView TopicCards(searchengine data, BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: data.DB_Mountains_Gone_To.length,
      itemBuilder: (BuildContext context, int index) {
        return Material(
          color: Colors.transparent,

          child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              splashColor: Colors.red,
              highlightColor: Colors.red,
              onTap: () {
                if (ontapselect == true) {
                  setState(() {
                    Provider.of<searchengine>(context, listen: false)
                        .Selected(data.DB_Mountains_Gone_To, index);

                  });
                }
              },
              onLongPress: () {
                setState(() {
                  Provider.of<searchengine>(context, listen: false).Selected(
                      data.DB_Mountains_Gone_To, index);
                  ontapselect = true;
                });
              },
              child: DataCard(data.DB_Mountains_Gone_To[index])),
        );
      },
      staggeredTileBuilder: (i) => StaggeredTile.fit(2),
    );
  }


  PreferredSize NormalAppBar() {
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        title: Text(appbar_text, style: TextStyle(color: Colors.green),),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  PreferredSize SelectedAppBar(BuildContext context) {
    int selected = Provider.of<searchengine>(context, listen: false)
        .NumSelected(Provider
        .of<searchengine>(context, listen: false)
        .DB_Mountains_Gone_To);
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        title: Text("Selected :" + selected.toString()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black12,
        actions: [
          IconButton(icon: Icon(Icons.close, color: Colors.red, size: 40,),
              onPressed: () {
                setState(() {
                  Provider.of<searchengine>(context, listen: false).Toggle_done(
                      Provider
                          .of<searchengine>(context, listen: false)
                          .DB_Mountains_Gone_To);
                  ontapselect = false;
                });
              })
        ],
      ),

    );
  }
}
class DataCard extends StatelessWidget {
  var mountain;

  DataCard(this.mountain);

  @override
  Widget build(BuildContext context) {
    //print(data);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Ink(
            child: FadeInImage(
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/Curve-Loading.gif'),
                image: mountain.photo!="none"?AssetImage('assets/'+mountain.photo):AssetImage('assets/no_image.jpg')
            )
        ),
        Ink(

          decoration: BoxDecoration(
            color:mountain.Selected==0?Theme.of(context).cardColor:Colors.red,
          ),

          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(

                "name: "+mountain.name,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 3,),
              Text(
                "country: "+mountain.country,
                style: TextStyle(fontSize: 18),

              ),
              SizedBox(height: 3,),
              Row(
                children: [
                  Text(
                    "height: "+mountain.height+" m",
                    style: TextStyle(fontSize: 18),

                  ),
                  mountain.Favorite==1?Icon(Icons.done,color: Colors.green,):Container(),
                ],
              ),
            ],
          ),
        ),],
    );
  }
}
class SeeMountains extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Ink(
            child: FadeInImage(
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/Curve-Loading.gif'),
                image: AssetImage('assets/Curve-Loading.gif'),
            )
        ),
        Ink(

          decoration: BoxDecoration(
            color:Colors.red,
          ),

          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Mountains are great climb and add the mountain you climbed to see here",
                style: TextStyle(fontSize: 18),
              ),

            ],
          ),
        ),],
    );
  }
}

class SearchNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Ink(
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/Curve-Loading.gif'),
              image: AssetImage('assets/Curve-Loading.gif'),
            )
        ),
        Ink(

          decoration: BoxDecoration(
            color:Colors.red,
          ),

          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "sorry looks like you wrote the country name wrong Or you did not visit the country yet",
                style: TextStyle(fontSize: 18),
              ),

            ],
          ),
        ),],
    );
  }
}
