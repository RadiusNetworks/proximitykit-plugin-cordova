package com.radiusnetworks.cordova.proximitykit;

import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import org.altbeacon.beacon.Beacon;
import org.altbeacon.beacon.BeaconData;
import org.altbeacon.beacon.Region;
import org.altbeacon.beacon.client.DataProviderException;

import com.radiusnetworks.proximity.ProximityKitManager;
import com.radiusnetworks.proximity.ProximityKitMonitorNotifier;
import com.radiusnetworks.proximity.ProximityKitRangeNotifier;
import com.radiusnetworks.proximity.ProximityKitSyncNotifier;
import com.radiusnetworks.proximity.ProximityKitBeacon;
import com.radiusnetworks.proximity.ProximityKitBeaconRegion;
import com.radiusnetworks.proximity.beacon.data.proximitykit.PkBeaconData;

import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class ProximityKitPlugin extends CordovaPlugin implements ProximityKitRangeNotifier, ProximityKitSyncNotifier, ProximityKitMonitorNotifier {

    public static final String ACTION_WATCH = "watchProximity";
    public static final String ACTION_CLEAR_WATCH = "clearWatch";

    public static final String EVENT_TYPE_KEY                     = "eventType";
    public static final String EVENT_TYPE_SYNCED                  = "didSync";
    public static final String EVENT_TYPE_ENTERED_REGION          = "didEnterRegion";
    public static final String EVENT_TYPE_EXITED_REGION           = "didExitRegion";
    public static final String EVENT_TYPE_DETERMINED_REGION_STATE = "didDetermineState";
    public static final String EVENT_TYPE_RANGED_BEACONS           = "didRangeBeacons";

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
    public static final String EVENT_BEACON_MANUFACTURER_KEY        = "manufacturer";
    public static final String EVENT_BEACON_DISTANCE_KEY         = "distance";
	
    private static ProximityKitManager pkManager;

    public HashMap<String, CallbackContext> watches = new HashMap<String, CallbackContext>();
    private boolean running = false;
    private ProximityKitCordovaApplication application;
    
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView)
    {
        super.initialize(cordova, webView);
        application = (ProximityKitCordovaApplication)cordova.getActivity().getApplicationContext();
        application.setPkPlugin(this);
        pkManager = application.getProximityKitManager();
    }

    @Override
    public void onDestroy()
    {
        super.onDestroy();
/*  [javac] /Users/James/Documents/_Radius/Cordova/hello-proximity-cordova/platforms/android/src/com/radiusnetworks/cordova/proximitykit/ProximityKitPlugin.java:85: error: cannot find symbol
    [javac]         pkManager.stop();
    [javac]                  ^
    [javac]   symbol:   method stop()
    [javac]   location: variable pkManager of type ProximityKitManager
*/
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

    public JSONObject pluginResultDidRangeBeacons(Collection<ProximityKitBeacon> beacons, ProximityKitBeaconRegion region) {
        JSONObject o = new JSONObject();
        try {
            o.put(EVENT_TYPE_KEY, EVENT_TYPE_RANGED_BEACONS);
            for (ProximityKitBeacon beacon : beacons) {
            	o.put(EVENT_BEACON_KEY, toJSON(beacon, region));
        	}
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return o;
    }

    private static final String TAG = "ProximityKitPlugin";
    
    @Override
    public void didRangeBeaconsInRegion(Collection<ProximityKitBeacon> beacons, ProximityKitBeaconRegion region) {
        sendSuccessMessageToAllWatches(pluginResultDidRangeBeacons(beacons, region));
    }

    @Override
    public void didEnterRegion(ProximityKitBeaconRegion region) {
        sendSuccessMessageToAllWatches(pluginResultDidEnterRegion(region));
    }

    @Override
    public void didExitRegion(ProximityKitBeaconRegion region) {
        sendSuccessMessageToAllWatches(pluginResultDidExitRegion(region));
    }

    @Override
    public void didDetermineStateForRegion(int state, ProximityKitBeaconRegion region) {
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
            regionJSON.put(EVENT_REGION_UUID_KEY, region.getId1());
            regionJSON.put(EVENT_REGION_MAJOR_KEY, region.getId2());
            regionJSON.put(EVENT_REGION_MINOR_KEY, region.getId3());
            //regionJSON.put(EVENT_REGION_ATTRIBUTES_KEY, new JSONObject(region.getAttributes()));
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return regionJSON;
    }

    private JSONObject toJSON(ProximityKitBeacon beacon, ProximityKitBeaconRegion region)
    {
        JSONObject beaconJSON = new JSONObject();
        try {        
            beaconJSON.put(EVENT_BEACON_UUID_KEY, beacon.getId1());
            beaconJSON.put(EVENT_BEACON_MAJOR_KEY, beacon.getId2());
            beaconJSON.put(EVENT_BEACON_MINOR_KEY, beacon.getId3());
            beaconJSON.put(EVENT_BEACON_MANUFACTURER_KEY, beacon.getManufacturer());
            beaconJSON.put(EVENT_BEACON_RSSI_KEY, beacon.getRssi());
            beaconJSON.put(EVENT_BEACON_DISTANCE_KEY, beacon.getDistance());
            beaconJSON.put(EVENT_BEACON_ATTRIBUTES_KEY, new JSONObject(beacon.getAttributes()));
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }

        return beaconJSON;
    }
}
