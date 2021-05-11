# GoCycling

## Available on the iOS App Store
https://apps.apple.com/ca/app/go-cycling/id1565861313

## App Icon

![alt text](Screenshots/GoCyclingDefaultIcon1024.png?raw=true)

## About

Go Cycling is a cycling tracker app built exclusively for iOS with SwiftUI. It is intended to be extremely easy to use for cyclists of all levels.

A key part of Go Cycling is it's privacy stance, there is no requirement for a sign in of any kind and all data is solely stored on the user's device. It also does not contain any advertisements.

Go Cycling makes use of many of Apple's frameworks and API's including:
* Core Location for location data
* MapKit for embedded maps throughout the app
* Core Data for persistent data storage of cycling routes and user preferences
* Combine for location update event processing

## System Requirements

This app is designed to support all iPhones and iPads with iOS14/iPadOS14 and above due to the use of the latest SwiftUI features.

For iPads, this includes support for both landscape and portait modes along with Slide Over and multitasking screen sizes.

## Usage

Note: For Go Cycling to track your current location, you must allow location access in Settings (the app will also ask for permission on the first launch). The location permissions must be set to "Always Allow" for location updates to occur while the app is not on the screen.

To use this app, first, start a new cycling route from the Cycle tab. The timer should start incrementing, you can choose to leave your device locked or unlocked.

While the route is ongoing you will see metrics on the Cycle tab of your current progress as well as your path on the map.

Once you are finished with your cycling route, you can compelete the route by using the stop button. The route will be saved to your device and is viewable in the History tab along with metrics about the route.

More routes can be created in this same way and they can all be viewed, sorted and deleted from the History tab.

## App Features

Go Cycling has many features packed into three tabs; Cycle, History and Settings. It also fully supports both light and dark mode, automatically setting the mode based on device settings.

Note: All screenshots shown were taken on an iPhone 12 Pro Max simulator.

### Features of the Cycle Tab
* Start, stop, pause and resume routes with the on-screen stopwatch
* View current cycling metrics, including distance cycled, speed and altitude
* Large map showing current location and path taken
* Timer showing cycling time of the ongoing route

### Device Screenshots of the Cycle Tab
Cycle Tab Without Ongoing Route | Cycle Tab Without Ongoing Route Dark | Cycle Tab With Ongoing Route | Cycle Tab With Ongoing Route Dark
------------------------------- | ------------------------------------ | ---------------------------- | ---------------------------------
![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/1.png?raw=true) | ![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/2.png?raw=true) | ![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/3.png?raw=true) | ![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/4.png?raw=true)

### Features of the History Tab
* View all past bike rides in an easily readable list
* Sort all of your bike rides by time, distance and date (all offering ascending or descending order)
* Click on a single bike ride to view a full screen view including a map of the route as well as metrics
* Each list entry is deletable by swiping to the left

### Device Screenshots of the History Tab
Cycling History List View | Cycling History List View Dark | Single Cycling Route Detailed View | Single Cycling Route Detailed View Dark
------------------------------- | ------------------------------------ | ---------------------------- | ---------------------------------
![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/5.png?raw=true) | ![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/6.png?raw=true) | ![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/7.png?raw=true) | ![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/8.png?raw=true)

### Settings Feautures Throughout the App
* Customize the app theme and app icon to fit your preferences
* Set your preferred units and customize the metrics view on the Cycle tab
* Option to reset all settings back to the defaults and delete all stored cycling routes
* Selected sort order in the History tab will persistent through future usage

### Device Screenshots for Some of the Settings Features
General Settings View | General Settings View Dark | Changing App Icon to Default Inverted | Setting Cycling History Sort Order
------------------------------- | ------------------------------------ | ---------------------------- | ---------------------------------
![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/9.png?raw=true) | ![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/10.png?raw=true) | ![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/12.png?raw=true) | ![alt text](Screenshots/App_Store_iPhone_12_Pro_Max/11.png?raw=true)

## Future Development

This app has been an immense amount of fun to develop and I have greatly enjoyed using SwiftUI! I am planning on continuing to add features as time permits and some ideas that are on my roadmap are listed below:
* Statistics tab displaying graphs about past cycling trends (also all time records such as longest route, furthest distance travelled in one month, etc)
  * Could also add goals to this, so that users could set cycling goals and track their progress towards them
* Route naming so that a user could assign a name to each route they complete
  * This would allow easy sorting by route names and comparison between attempts of the same route
* Calorie tracking within the app as an optional metric
* Route generator feature where a user could enter the distance they want to ride and the app could suggest a route for them

Thank you very much for viewing this project!
