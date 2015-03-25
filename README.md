ProximityKit Plugin for Cordova/PhoneGap
========================================

Last Updated 15-October-2014

Installation
------------
The plugin is distributed via Github.

To add the plugin to your project, run the following command:

```
$ cordova plugin add https://github.com/RadiusNetworks/proximitykit-plugin-cordova
```

This will add the plugin to your project's `config.xml` file and will copy various files into the native `src` directory for your platforms.

### iOS only

For iOS, Proximity Kit uses SQLite internally but just needs the default library included on iOS. So you need to link to it in the project in Xcode manually after the app is built in Cordova/PhoneGap.  To do this, open the generated Xcode project found under `platforms`/`ios` and follow these steps:

1. Select the App's target in Xcode
1. Choose "Build Phases"
1. Under the "Link Binary With Libraries" section click the '+' to add another library
1. Choose libsqlite3.dylib and click "Add"

### Android only

To properly implement the custom application subclass that initiates the beacon monitoring, edit the `AndroidManifest.xml` file (`platforms`/`android`/`AndroidManifest.xml`) to include the proper `android:name` tag under `application` for the `ProximityKitCordovaAppication` class.  The application header should look like this:

    <application android:name="com.radiusnetworks.cordova.proximitykit.ProximityKitCordovaApplication" android:hardwareAccelerated="true" android:icon="@drawable/icon" android:label="@string/app_name">

Adding the plugin will also modify other parts of your `AndroidManifest.xml` automatically.  Please do not remove the `<service>`, `<receiver>`, and `<uses-permission>` elements that are added to this file or the plugin will not work properly.


ProximityKit Integration
---
In order to provide the necessary ProximityKit configuration data to the native apps, download the `ProximityKit.plist` (for iOS) and/or `ProximityKit.properties` (for Android) for your kit.  These files need to be in the following location within your project depending on the platform being built:

| Platform | Location of ProximityKit configuration file         |
|:---------|:----------------------------------------------------|
| iOS      | `./platforms/ios/<Project Name>/ProximityKit.plist` |
| Android  | `./platforms/android/src/ProximityKit.properties`   |

### iOS only

In addition to placing the `ProximityKit.plist` file inside the iOS project's directory structure, you need to add the file to the Xcode project and to the appropriate target:

1. Open the project in Xcode
2. Select the App's target and select "Add Files to "..." from the File menu.
3. Locate your ProximityKit.plist file and click "Add"


Usage
-----
By successfully adding the ProximityKit plugin to your project, there is no need to explicitly require any ProximityKit Javascript files in your own code.  The plugin manifests itself in Javascript as `radiusnetworks.plugins.proximitykit`. There are two methods on this object: `watchProximity` and `clearWatch`.

### `watchProximity(successHandler, failureHandler) returns watchId`

`successHandler` is a function that receives a `message` object from ProximityKit on a periodic basis.  The `message` object always has an `eventType` associated with it which is a String. `failureHandler` is a function that receives a `message` containing the failure message as a String.  `watchId` returned by the call should be stored and eventually passed into `clearWatch` when the callbacks are no longer needed.

`eventType` values:

|Value              | Event                               |
|:------------------|:------------------------------------|
|`didSync`          | ProximityKit synced with the server |
|`didDetermineState`| State determined for region         |
|`didEnterRegion`   | Region entered                      |
|`didExitRegion`    | Region exited                       |
|`didRangeBeacon`   | A beacon is in range                |

Based on the `eventType`, there may be additional items in the `message`.

`didSync`

No additional data.

`didDetermineState`

Additional data:

|Value              | Description                                              |
|:------------------|:---------------------------------------------------------|
|`regionState`      | 0 - state unknown, 1 - inside region, 2 - outside region |
|`region`           | Region data                                              |

`didEnterRegion`
`didExitRegion`

Additional data:

|Value              | Description                                              |
|:------------------|:---------------------------------------------------------|
|`region`           | Region data                                              |

`didRangeBeacon`

Additional data:

|Value              | Description                                              |
|:------------------|:---------------------------------------------------------|
|`beacon`           | Beacon data                                              |



### `clearWatch(watchId)`

Cancels callbacks from ProximityKit.  This method should be called with a `watchId` previously returned by a call to `watchProximity`.

### Region Data

|Value              | Description                                              |
|:------------------|:---------------------------------------------------------|
|`name`             | Region name                                              |
|`identifier`       | Region UUID                                              |
|`attributes`       | ProximityKit attributes associated with the region       |


### Beacon Data

|Value              | Description                                              |
|:------------------|:---------------------------------------------------------|
|`uuid`             | Beacon UUID                                              |
|`major`            | Beacon major value                                       |
|`minor`            | Beacon minor value                                       |
|`rssi`             | Beacon RSSI                                              |
|`proximity`        | Beacon proximity (0 - unknown, 1 - immediate, 2 - near, 3 - far) |
|`attributes`       | ProximityKit attributes associated with the beacon       |

### Constants

A number of constants for the above keys and event types are available via `radiusnetworks.plugins.proximitykit.constants`.

Removal
-------

To remove the plugin from your project, run the following command:

```
$ cordova plugin rm com.radiusnetworks.cordova.proximitykit
```

You may also delete the `ProximityKit.plist` and/or `ProximityKit.properties` file(s) from your project directory (and your Xcode project on iOS).

Reference Implementation
-------

A reference Cordova project implementing the Proximity Kit plugin can be found [here](https://github.com/RadiusNetworks/hello-proximity-cordova).  Clone this project and follow the steps to be detecting beacons in both iOS and Android in minutes.

Support
-------

For support questions or other concerns, email support@radiusnetworks.com
