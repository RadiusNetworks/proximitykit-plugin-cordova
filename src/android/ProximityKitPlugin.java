package com.radiusnetworks.cordova.proximity;

import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.radiusnetworks.ibeacon.IBeacon;
import com.radiusnetworks.ibeacon.IBeaconData;
import com.radiusnetworks.ibeacon.Region;
import com.radiusnetworks.ibeacon.client.DataProviderException;
import com.radiusnetworks.proximity.ProximityKitManager;
import com.radiusnetworks.proximity.ProximityKitNotifier;
import com.radiusnetworks.proximity.ibeacon.data.proximitykit.PkIBeaconData;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class ProximityKitPlugin extends CordovaPlugin implements ProximityKitNotifier {

    public static final String ACTION_WATCH = "watchProximity";
    public static final String ACTION_CLEAR_WATCH = "clearWatch";

    public static final String EVENT_TYPE_KEY                     = "eventType";
    public static final String EVENT_TYPE_SYNCED                  = "didSync";
    public static final String EVENT_TYPE_ENTERED_REGION          = "didEnterRegion";
    public static final String EVENT_TYPE_EXITED_REGION           = "didExitRegion";
    public static final String EVENT_TYPE_DETERMINED_REGION_STATE = "didDetermineState";
    public static final String EVENT_TYPE_RANGED_BEACON           = "didRangeBeacon";

    public static final String EVENT_REGION_KEY                   = "region";
    public static final String EVENT_REGION_NAME_KEY              = "name";
    public static final String EVENT_REGION_UUID_KEY              = "uuid";
    public static final String EVENT_REGION_MAJOR_KEY             = "major";
    public static final String EVENT_REGION_MINOR_KEY             = "minor";
    public static final String EVENT_REGION_IDENTIFIER_KEY        = "identifier";
    public static final String EVENT_REGION_ATTRIBUTES_KEY        = "attributes";
    public static final String EVENT_REGION_STATE_KEY             = "state";

    public static final String EVENT_BEACONS_KEY                  = "beacons";
    public static final String EVENT_BEACON_KEY                   = "beacon";

    public static final String EVENT_BEACON_UUID_KEY              = "uuid";
    public static final String EVENT_BEACON_MAJOR_KEY             = "major";
    public static final String EVENT_BEACON_MINOR_KEY             = "minor";
    public static final String EVENT_BEACON_RSSI_KEY              = "rssi";
    public static final String EVENT_BEACON_ATTRIBUTES_KEY        = "attributes";
    public static final String EVENT_BEACON_IDENTIFIER_KEY        = "identifier";
    public static final String EVENT_BEACON_PROXIMITY_KEY         = "proximity";

    private static ProximityKitManager pkManager;

    public HashMap<String, CallbackContext> watches = new HashMap<String, CallbackContext>();
    private boolean running = false;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView)
    {
        super.initialize(cordova, webView);
        pkManager = ProximityKitManager.getInstanceForApplication(cordova.getActivity().getApplicationContext());
        pkManager.setNotifier(this);
        pkManager.getIBeaconManager().setDebug(true);
    }

    @Override
    public void onDestroy()
    {
        super.onDestroy();
//        pkManager.stop();
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        Log.d(TAG, "execute: action is " + action + ", args is " + args.toString());
        boolean handled = false;
        if (action.equals(ACTION_WATCH)) {
            String watchId = args.getString(0);
            this.watchProximity(watchId, callbackContext);
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
        addWatch(watchId, callbackContext);
    };

    private void clearWatch(String watchId, CallbackContext callbackContext) {
        removeWatch(watchId);
    };

    private void addWatch(String timerId, CallbackContext callbackContext) {
        watches.put(timerId, callbackContext);
        if (watches.size() == 1) {
            start();
        }
    }

    private void removeWatch(String timerId) {
        if (watches.containsKey(timerId)) {
            watches.remove(timerId);
        }
        if (watches.size() == 0) {
            stop();
        }
    }

    public void success(JSONObject message, CallbackContext callbackContext, boolean keepCallback) {
        PluginResult result = new PluginResult(PluginResult.Status.OK, message);
        result.setKeepCallback(keepCallback);
        callbackContext.sendPluginResult(result);
    }

    private void sendSuccessMessageToAllWatches(JSONObject jsonMessage)
    {
        Iterator<CallbackContext> it = this.watches.values().iterator();
        while (it.hasNext()) {
            success(jsonMessage, it.next(), true);
        }
    }

    private void start() {
        if (! running) {
            Log.d(TAG, "Starting pkManager");
            running = true;
            pkManager.start();
        }
    }

    private void stop() {
        if (running) {
//            pkManager.stop();
            running = false;
        }
    }

    public JSONObject pluginResultDidSync() {
        JSONObject o = new JSONObject();

        try {
            o.put(EVENT_TYPE_KEY, EVENT_TYPE_SYNCED);
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return o;
    }

    public JSONObject pluginResultDidDetermineState(int state, Region region) {
        JSONObject o = new JSONObject();

        try {
            o.put(EVENT_TYPE_KEY, EVENT_TYPE_DETERMINED_REGION_STATE);
            o.put(EVENT_REGION_STATE_KEY, state);
            o.put(EVENT_REGION_KEY, toJSON(region));
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return o;
    }

    public JSONObject pluginResultDidEnterRegion(Region region) {
        JSONObject o = new JSONObject();

        try {
            o.put(EVENT_TYPE_KEY, EVENT_TYPE_ENTERED_REGION);
            o.put(EVENT_REGION_KEY, toJSON(region));
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return o;
    }

    public JSONObject pluginResultDidExitRegion(Region region) {
        JSONObject o = new JSONObject();

        try {
            o.put(EVENT_TYPE_KEY, EVENT_TYPE_EXITED_REGION);
            o.put(EVENT_REGION_KEY, toJSON(region));
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return o;
    }

    public JSONObject pluginResultDidRangeBeacon(IBeacon beacon, IBeaconData beaconData) {
        JSONObject o = new JSONObject();
        try {
            o.put(EVENT_TYPE_KEY, EVENT_TYPE_RANGED_BEACON);
            o.put(EVENT_BEACON_KEY, toJSON(beacon, beaconData));
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return o;
    }

    private static final String TAG = "ProximityKitPlugin";

    @Override
    public void iBeaconDataUpdate(IBeacon iBeacon,
                                  IBeaconData iBeaconData,
                                  DataProviderException e) {
        sendSuccessMessageToAllWatches(pluginResultDidRangeBeacon(iBeacon, iBeaconData));
    }

    @Override
    public void didEnterRegion(Region region) {
        sendSuccessMessageToAllWatches(pluginResultDidEnterRegion(region));
    }

    @Override
    public void didExitRegion(Region region) {
        sendSuccessMessageToAllWatches(pluginResultDidExitRegion(region));
    }

    @Override
    public void didDetermineStateForRegion(int state, Region region) {
        sendSuccessMessageToAllWatches(pluginResultDidDetermineState(state, region));
    }

    @Override
    public void didSync()
    {
        sendSuccessMessageToAllWatches(pluginResultDidSync());
    }

    @Override
    public void didFailSync(Exception e)
    {
        Log.d(TAG, "didFailSync", e);
    }

    private JSONObject toJSON(Region region)
    {
        JSONObject regionJSON = new JSONObject();
        try {
            regionJSON.put(EVENT_REGION_UUID_KEY, region.getProximityUuid());
            regionJSON.put(EVENT_REGION_MAJOR_KEY, region.getMajor());
            regionJSON.put(EVENT_REGION_MINOR_KEY, region.getMinor());
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return regionJSON;
    }

    private JSONObject toJSON(IBeacon beacon,
                              IBeaconData beaconData)
    {
        JSONObject beaconJSON = new JSONObject();
        try {
            beaconJSON.put(EVENT_BEACON_UUID_KEY, beacon.getProximityUuid());
            beaconJSON.put(EVENT_BEACON_MAJOR_KEY, beacon.getMajor());
            beaconJSON.put(EVENT_BEACON_MINOR_KEY, beacon.getMinor());
            beaconJSON.put(EVENT_BEACON_RSSI_KEY, beacon.getRssi());
            beaconJSON.put(EVENT_BEACON_PROXIMITY_KEY, beacon.getProximity());
            beaconJSON.put(EVENT_BEACON_ATTRIBUTES_KEY, new JSONObject(((PkIBeaconData) beaconData).getAttributes()));
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return beaconJSON;
    }
}
