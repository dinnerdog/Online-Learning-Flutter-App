# Kind Hearts Online Learning App

Welcome to the Kind Hearts Online Learning App! This app is part of my master's project and is built using Flutter and Firebase. It provides various features targeting early students aged 8-12 years old. All assets used in this app are non-copyright, so you can use them without concerns.

## Features

1. Authentication: Offers sign-up and login functionality using email and password, powered by Firebase Authentication.
2. Profile: Enables users to view and edit their personal profiles.
3. Contacts: Provides a chatroom and an overview of all registered users.
4. Courses: Allows users to upload and share educational resources, view course details, and handle assignment-related tasks.
5. Games: Includes three games built using the Flame engine.
6. Activity: Features an "Events" section similar to Facebook, allowing students to engage in various activities.

## Main Deployment Elements and Versions

Dart SDK: 3.3.2 (>=3.3.0 <4.0.0)
Flutter SDK: 3.19.4
Android SDK: 32 (>=16)
iOS: 16.0 (>=12)
firebase_core: 2.25.4
firebase_auth: 4.17.5
cloud_firestore: 4.15.6
bloc: 8.1.3
flutter_bloc: 8.1.4
firebase_storage: 11.6.7

## How to Use

### Step 1: Clone the Project
Clone this repository to your local machine:
bash
Copy code
git clone https://github.com/dinnerdog/Online-Learning-App-Using-Flutter.git
Change to the project's directory:
bash
Copy code
cd Online-Learning-App-Using-Flutter

### Step 2: Set Up Firebase
Login to Firebase:  

Install FlutterFire CLI:  
Please see https://firebase.google.com/docs/flutter/setup?platform=android, the offical tutorial for information that installing the FLutterFire CLI and set up your Firebase.  
Log into Firebase using your Google account by running the following command:  
```firebase login```
### Step 3: Configure Firebase for the App
Use the FlutterFire CLI to configure your Flutter apps to connect to Firebase.  
From the Flutter project directory, run the following command to start the configuration workflow:  
```flutterfire configure```
This command sets up Firebase services for your Flutter app.  

### Step 4: Fill Up the Api keys
In files:  
1. android/app/src/main/AndroidManifest.xml  
2. ios/Runner/AppDelegate.swift  
3. activity_add.dart  
4. activity_detail.dart  
Fill up all the api key using the Google Api. Please make sure you applied the Google Api for google map. See more information in https://console.cloud.google.com/google/maps-apis/onboard?utm_source=Docs_GS_Button&ref=https:%2F%2Fdevelopers.google.com%2Fmaps%2F&hl=zh-cn.

### Step 5: Run the App  
In your terminal, execute:  
```dart pub get ```
then run  
```flutter run```
Everythng is ready to go.  


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
