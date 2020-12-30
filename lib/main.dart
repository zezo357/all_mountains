
import 'package:flutter/material.dart';
import 'package:all_mountains/screens/PhotosView.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'engine.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<searchengine>(
        create: (context)=> searchengine(),
      child: MaterialApp(
        darkTheme: ThemeData.dark(),
        theme: ThemeData.light(),
        home: MyHomePage(
          title: "Quotes Topics",
        ),

      ),
    );
  }
}
// TODO: add pictures to the ui and try to improve it
// TODO: make the ui grid view
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool ontapselect = false;
  ScrollController controller;
  TextEditingController txt =new TextEditingController();
  String appbar_text="Mountains";
  @override
  void dispose() {
    txt.dispose();
    controller.removeListener(_scrollListener);
    super.dispose();
  }
  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    onStart();
  }

  void onStart() async {
    await Provider.of<searchengine>(context, listen: false)
        .CheckNewDatabaseVersion(); //check for any changes in the database"to be able to add funcnalioty"
    await Provider.of<searchengine>(context, listen: false)
        .RowsCount(); //check local DB rows
    if (Provider
        .of<searchengine>(context, listen: false)
        .DB_Row_count == 0) { //if the local DB has 0 rows
      Provider.of<searchengine>(context, listen: false).DataToEncoded();
      await Provider.of<searchengine>(context, listen: false).UpdateDB(Provider.of<searchengine>(context, listen: false).DB_Mountains);
      await Provider.of<searchengine>(context, listen: false).ReadDB();

    }
    else {
      await Provider.of<searchengine>(context, listen: false).ReadDB();
    }
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

          showModalBottomSheet(context: context,isScrollControlled: true, builder: (ctx){
            return Container(
              padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0,10.0, 10.0),
            child: TextFormField(
              autofocus: true,
              controller: txt,
              onFieldSubmitted:(value) {Navigator.pop(context);
              setState(() {
                appbar_text="country: "+value;
              });
              if(value==""){Provider.of<searchengine>(context, listen: false).ReadDB();
              setState(() {
                appbar_text="Mountains";
              });}
              },
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
                hintStyle:TextStyle(   fontSize: 24,
                  color: Theme.of(context).textTheme.bodyText1.color,
                ),
                labelText: 'Country',labelStyle:TextStyle(fontSize: 18,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),

              ),
              style:TextStyle(   fontSize: 24,
                  color: Theme.of(context).textTheme.bodyText1.color
              ),

              onChanged: (value){
                setState(() {
                  appbar_text="country: "+value;
                });
                Provider.of<searchengine>(context, listen: false).getspecificcountry(value);
              },
            ),
            ),
            );
          }
          );
        },

      ),

      backgroundColor: Colors.grey[900],
      appBar: Provider.of<searchengine>(context, listen: false).SelectedExist(
          Provider
              .of<searchengine>(context, listen: false)
              .DB_Mountains_readable) == true ? SelectedAppBar(context) : NormalAppBar(),

      body: Consumer<searchengine>(
          builder: (context, searchengine data, child) {
            return data.DB_Mountains_readable.length != 0
                ? TopicCards(data, context)
                : appbar_text!="Mountains"?SearchNotFound():Center(child: CircularProgressIndicator(
              backgroundColor: Colors.black,),);
          }
      ),
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.

    );
  }

  StaggeredGridView TopicCards(searchengine data, BuildContext context) {
    return StaggeredGridView.countBuilder(
        controller: controller,
        crossAxisCount: 4,
        itemCount: data.DB_Mountains_readable.length,
        itemBuilder: (BuildContext context, int index) {
          return Material(
            color: Colors.transparent,

            child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                splashColor: Colors.green,
                highlightColor: Colors.green,
                onTap: () {
                  if (ontapselect == true) {
                    setState(() {
                      Provider.of<searchengine>(context, listen: false)
                          .Selected(data.DB_Mountains_readable, index);

                    });
                  }
                },
                onLongPress: () {
                  setState(() {
                    Provider.of<searchengine>(context, listen: false).Selected(
                        data.DB_Mountains_readable, index);
                    ontapselect = true;
                  });
                },
                child: DataCard(data.DB_Mountains_readable[index])),
          );
        },
        staggeredTileBuilder:(i)=> StaggeredTile.fit(2),
    );
  }

  Route _createRoute(var document) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          GoneTolist(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1, 0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  PreferredSize NormalAppBar() {
    if (Provider.of<searchengine>(context, listen: false).NumSelected(Provider
        .of<searchengine>(context, listen: false)
        .DB_Mountains_readable) == 0) {
      ontapselect = false;
    }
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        title: Text(appbar_text),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(icon: Icon(Icons.done, color: Colors.green, size: 40,),
              onPressed: () {
                Navigator.of(context).push(_createRoute("Gone To"));
              })
        ],
      ),
    );
  }

  PreferredSize SelectedAppBar(BuildContext context) {
    int selected = Provider.of<searchengine>(context, listen: false)
        .NumSelected(Provider
        .of<searchengine>(context, listen: false)
        .DB_Mountains_readable);
    return PreferredSize(
      preferredSize: const Size(double.infinity, kToolbarHeight),
      child: AppBar(
        title: Text("Selected :" + selected.toString()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[800],
        actions: [
          IconButton(icon: Icon(Icons.done, color: Colors.green, size: 40,),
              onPressed: () {
                setState(() {
                  Provider.of<searchengine>(context, listen: false).Toggle_done(
                      Provider
                          .of<searchengine>(context, listen: false)
                          .DB_Mountains_readable);
                  ontapselect = false;
                });
              })
        ],
      ),

    );
  }

  void _scrollListener() {
    //print(controller.position.extentAfter);
    if (controller.position.extentAfter < 500) {
          Provider.of<searchengine>(context, listen: false).add10();

    }
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
            color:mountain.Selected==0?Theme.of(context).cardColor:Colors.green,
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
                "sorry looks like you wrote the country name wrong",
                style: TextStyle(fontSize: 18),
              ),

            ],
          ),
        ),],
    );
  }
}
