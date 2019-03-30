import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_share_me/flutter_share_me.dart';

const offset = 10.0;
const padding = EdgeInsets.all(offset);

void main() => runApp(
MaterialApp(
title: 'Flutter Create',
debugShowCheckedModeBanner: false,
theme: ThemeData(
accentColorBrightness: Brightness.dark,
textTheme: TextTheme(
title: TextStyle(
fontSize: 22, fontFamily: 'Lobster', color: Colors.white))),
home: Editor(),
routes: {'/share': (_) => Sharing()},
),
);

class Line {
final int offset;
final List<Word> words;

Line(this.words, this.offset) : assert(words != null);

factory Line.fromDb(data) => Line(
(data['words'] as List)?.map((w) => Word.fromDb(w))?.toList(),
data['offset'] ?? 0,
);
}

class Word {
final String s;
final int type;
final bool rqd;

Word(this.s, this.type, this.rqd) : assert(s != null);

factory Word.fromDb(data) => Word(
data["s"],
data["type"] ?? 0,
data["r"] ?? false,
);
}

class Editor extends StatefulWidget {
Editor({Key key}) : super(key: key);

@override
_EditorState createState() => new _EditorState();
}

class _EditorState extends State<Editor> {
@override
Widget build(_) {
return Scaffold(
backgroundColor: Color(0xff292c3f),
body: SafeArea(
child: StreamBuilder<QuerySnapshot>(
stream:
Firestore.instance.collection('code').orderBy("line").snapshots(),
builder: (_, sn) => !sn.hasData
? LinearProgressIndicator()
: Code(
code: sn.data.documents.map((r) => Line.fromDb(r)).toList(),
colors: [
0xff9fc174,
0xFFab95c3,
0xFFf8caa8,
0xFF8c9ae3,
0xffc8d4d2
].map((c) => Color(c)).toList()),
),
),
);
}
}

class Code extends StatefulWidget {
final List<Line> code;
final List<Color> colors; // text, var, class, func, symb

Code({Key key, @required this.code, @required this.colors}) : super(key: key);

_CodeState createState() => _CodeState(code);
}

class _CodeState extends State<Code> with SingleTickerProviderStateMixin {
List<Line> _code;
int _weight;
int _initial;
bool _isWrong = false;
Animation<double> _anim;
AnimationController _cntr;

_CodeState(this._code) : assert(_code != null) {
_weight =
_code.fold(0, (a, b) => (a + b.words.where((w) => !w.rqd).length));
_initial = _weight;
}

@override
void initState() {
_cntr = new AnimationController(
duration: Duration(milliseconds: 200), vsync: this);
_anim = new Tween<double>(begin: 0, end: 1).animate(_cntr)
..addListener(() => setState(() {}))
..addStatusListener((s) async {
if (s != AnimationStatus.completed) return;
if (_isWrong) {
try {
await _cntr.reverse().orCancel;
_isWrong = false;
} on TickerCanceled {}
} else {
_weight--;
_cntr.reset();
if (_weight == 0) {
await Future.delayed(const Duration(seconds: 2));
Navigator.pushReplacementNamed(context, '/share');
}
}
});
super.initState();
}

@override
Widget build(c) {
final size = MediaQuery.of(c).size;
return Stack(children: <Widget>[
Align(
child: Container(
color: (_isWrong ? Colors.red : Colors.white)
.withAlpha((_anim.value * 35 + 20).toInt()),
width: size.width,
height: size.height * (1 - (_weight - _anim.value) / _initial),
),
alignment: Alignment.bottomCenter,
),
ListView.builder(
physics: BouncingScrollPhysics(),
itemCount: _code.length,
padding: padding,
itemBuilder: (_, i) => Padding(
padding: const EdgeInsets.only(top: offset / 2),
child: Wrap(
spacing: offset / 2,
runSpacing: offset / 2,
crossAxisAlignment: WrapCrossAlignment.center,
children: [SizedBox(width: offset * _code[i].offset)]
..addAll(_code[i].words.map((w) => _word(w, i)).toList()),
),
),
)
]);
}

Widget _word(Word w, int i) {
final clr = widget.colors[w.type];
return InkWell(
onTap: () => _onRemove(w, i),
splashColor: clr.withAlpha(70),
child: Container(
padding: padding,
color: clr.withAlpha(15),
child: Text(w.s, style: Theme.of(context).textTheme.title.copyWith(color: clr)),
),
);
}

void _onRemove(Word w, int i) async {
if (_cntr.isAnimating) return;

_isWrong = w.rqd;
if (!_isWrong) {
_code[i].words.remove(w);
if (_code[i].words.isEmpty) _code.removeAt(i);
}
_cntr.forward();
}
}

class Sharing extends StatefulWidget {
@override
_SharingState createState() => new _SharingState();
}

class _SharingState extends State<Sharing> {
String _who = 'I';

@override
Widget build(c) {
final style = Theme.of(c).textTheme.title;
return Scaffold(
backgroundColor: Colors.white,
body: SafeArea(
child: Center(
child: Text(
"$_who ❤️ Flutter!",
style: style.copyWith(fontSize: 50, color: Colors.black),
),
),
),
floatingActionButton: FloatingActionButton.extended(
backgroundColor: Colors.redAccent,
icon: Icon(Icons.share),
label: Text('Share', style: style),
onPressed: () async {
if (await FlutterShareMe().shareToTwitter(
msg: 'I ❤️ Flutter! #Flutter #FlutterCreate') ==
'success') {
setState(() {
_who = 'We';
});
}
},
),
);
}
}