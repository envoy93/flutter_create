# Flutter Create
A simple application for [Flutter Create Participation](https://flutter.dev/create)

<img src="/1.jpg" width="40%"> &nbsp; <img src="/2.jpg" width="40%">

## Description
<img src="/1.gif">

This is the most useless application in the world. When launched, the application loads data from my firebase and displays it as if it were code in a text editor.
Next, the user must reduce the amount of code by clicking on the words.
When the user deletes all unnecessary words, a new useless screen will open, on which the user can share a post.

_In this app I used a database, animations, some material widgets, a custom font._

## Install
Since I don't have a Mac OS, I could not add Cloud Firestore support for iOS, so *it can only be run under android*.

### Using Github
1. Clone the repo https://github.com/envoy93/flutter_create
2. Cd into the flutter_create directory
3. Attach Android device
4. In bash run: flutter run --release

### Using Zip
1. Download the zipfile: flutter_create.zip
2. Extract the contents of the zipfile
3. Cd into the flutter_create directory
4. Attach Android device
5. In bash run: flutter run --release

## Packages Used
 - [cloud_firestore](https://pub.dartlang.org/packages/cloud_firestore)
 - [flutter_share_me](https://pub.dartlang.org/packages/share)

##### Created by Kirill Shashov, March 2019
