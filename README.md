ProximityKit Plugin for Cordova/PhoneGap
========================================

Last Updated 06-June-2014

Michael Harper (mharper@standalonecode.com)

Directory Structure
-------------------

`plugin.xml` This is the file that defines the configuration of the ProximityKit plugin.

`src`<br/>
`+android` This is where the Android code for the plugin lives as well as the ProximityKit library.

`+ios` This is where the iOS code for the plugin lives as well as the ProximityKit framework.

`www` Javascript bridging a PhoneGap app to the native code resides here.

`plugin.xml` Anatomy
------------------

`plugin` -- the root element. We've defined the plugin `id` as `com.radiusnetworks.cordova.proximity`. This is the id that is used to remove the plugin from a project after it is installed, e. g.:

```
$ cordova plugin rm com.radiusnetworks.cordova.proximity
```

Eventually, it will also be used for installing the plugin into a project.  For now, that is done using the path to the plugin directory:

```
$ cordova plugin add <path_to_plugin_directory>
```

The `version` attribute of the plugin is what you expect it is.

`name` is the descriptive moniker for the plugin, which is ProximityKit in this case.  It plays no further part in the equation other than being descriptive.

`description` is a more verbose version of `name`.

`platform` is where things get interesting and can break easily.  There are two `platform` elements: one for iOS and one for Android.

`<platform name="ios">` defines the configuration for iOS. It contains:

```
    <js-module name="proximitykit" src="www/proximitykit.js">
      <clobbers target="cordova.plugins.proximitykit" />
    </js-module>
```
The `src` attribute in the `js-module` element specifies the location of the plugin Javascript code for this platform. `clobbers target=` tells how the plugin will make its API available to the client app.  In this case, the client app can access the ProximityKit plugin interface by referencing `cordova.plugins.proximitykit` as a Javascript object.