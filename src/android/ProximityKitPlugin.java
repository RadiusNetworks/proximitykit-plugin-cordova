package com.radiusnetworks.cordova.proximity;

import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.radiusnetworks.ibeacon.IBeacon;
import com.radiusnetworks.ibeacon.IBeaconData;
import com.radiusnetworks.ibeacon.Region;
import com.radiusnetworks.ibeacon.client.DataProviderException;
import com.radiusnetworks.proximity.ProximityKitManager;
import com.radiusnetworks.proximity.ProximityKitNotifier;

public class ProximityKitPlugin extends CordovaPlugin implements ProximityKitNotifier {

    public static final String ACTION_WATCH = "watchProximity";
    public static final String ACTION_CLEAR_WATCH = "clearWatch";

    private static ProximityKitManager pkManager;

  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView)
  {
    super.initialize(cordova, webView);
    pkManager = ProximityKitManager.getInstanceForApplication(cordova.getActivity().getApplicationContext());
    pkManager.setNotifier(this);
    pkManager.getIBeaconManager().setDebug(true);
    pkManager.start();
  }
  
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        boolean handled = false;
        if (action.equals(ACTION_WATCH)) {
            this.watchProximity(callbackContext);
            handled = true;
        }
        else if (action.equals(ACTION_CLEAR_WATCH)) {
            String watchId = args.getString(0);
            this.clearWatch(watchId, callbackContext);
            handled = true;
        }
        return handled;
    }

    private void watchProximity(CallbackContext callbackContext) {
    };

    private void clearWatch(String watchId, CallbackContext callbackContext) {
    };

    private static final String TAG = "ProximityKitPlugin";

@Override
public void iBeaconDataUpdate(IBeacon iBeacon,
                              IBeaconData iBeaconData,
                              DataProviderException e) {
    Log.d(TAG, "updated " + iBeacon + "[" + iBeaconData + "]", e);
}

@Override
public void didEnterRegion(Region region) {
    Log.d(TAG, "entered " + region);
}

@Override
public void didExitRegion(Region region) {
    Log.d(TAG, "exited " + region);
}

@Override
public void didDetermineStateForRegion(int i, Region region) {
    Log.d(TAG, "state " + i + "(" + region + ")");
}

@Override
public void didSync() {
    Log.d(TAG, "successful sync");
}

@Override
public void didFailSync(Exception e) {
    Log.d(TAG, "failed sync", e);
}
}
