package com.radiusnetworks.cordova.proximity;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class CDVProximityKitPlugin extends CordovaPlugin {

    public static final String ACTION_INITIALIZE = "initialize";
    public static final String ACTION_WATCH = "watch";
    public static final String ACTION_CLEAR_WATCH = "clearWatch";

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        boolean handled = false;
        if (action.equals(ACTION_INITIALIZE)) {
            this.initialize(callbackContext);
            handled = true;
        }
        else if (action.equals(ACTION_WATCH)) {
            this.watch(callbackContext);
            handled = true;
        }
        else if (action.equals(ACTION_CLEAR_WATCH)) {
            String watchId = args.getString(0);
            this.clearWatch(watchId, callbackContext);
            handled = true;
        }
        return handled;
    }

    private void watchProximity(String watchId, CallbackContext callbackContext) {
    };

    private void clearWatch(String watchId, CallbackContext callbackContext) {
    };
}
