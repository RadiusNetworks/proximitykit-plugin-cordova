var exec = require('cordova/exec');

var pluginClass = "ProximityKit";

exports.watchProximity = function(success, error) {
    exec(success, error, pluginClass, "watchProximity", []);
};

exports.clearWatch = function(success, error) {
    exec(success, error, pluginClass, "clearWatch", []);
};
