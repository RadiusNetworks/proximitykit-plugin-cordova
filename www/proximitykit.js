var exec = require('cordova/exec');

var pluginClass = "ProximityKit";

exports.constants = {
  'keys' : {
    'eventType' : 'eventType',
    'region' : 'region',
    'state' : 'state',
    'name' : 'name',
    'identifier' : 'identifier',
    'attributes' : 'attributes',
    'uuid' : 'uuid',
    'major' : 'major',
    'minor' : 'minor',
    'rssi' : 'rssi',
    'proximity' : 'proximity',
    'beacons' : 'beacons'
  },
  'eventTypes' : {
    'sync' : 'didSync',
    'determinedRegionState' : 'didDetermineState',
    'enteredRegion' : 'didEnterRegion',
    'exitedRegion' : 'didExitRegion',
    'rangedBeacons' : 'didRangeBeacons'
  }
};

exports.watchProximity = function(success, error) {
    exec(success, error, pluginClass, "watchProximity", []);
};

exports.clearWatch = function(success, error) {
    exec(success, error, pluginClass, "clearWatch", []);
};
