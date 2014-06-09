var exec = require('cordova/exec');

var pluginClass = "ProximityKit";

exports.constants = {
  'keys' : {
    'eventType' : 'eventType',
    'region' : 'region',
    'beacons' : 'beacons',
    'regionState' : 'regionState'
  },
  'eventTypes' : {
    'sync' : 'didSync',
    'determinedRegionState' : 'didDetermineState',
    'enteredRegion' : 'didEnter',
    'exitedRegion' : 'didExit',
    'rangedBeacons' : 'didRangeBeacons'
  }
};

exports.watchProximity = function(success, error) {
    exec(success, error, pluginClass, "watchProximity", []);
};

exports.clearWatch = function(success, error) {
    exec(success, error, pluginClass, "clearWatch", []);
};
