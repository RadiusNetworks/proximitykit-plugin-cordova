package com.radiusnetworks.cordova.proximitykit;

import android.util.Log;
import android.app.Application;

import com.radiusnetworks.proximity.ProximityKitManager;
import com.radiusnetworks.proximity.ProximityKitMonitorNotifier;
import com.radiusnetworks.proximity.ProximityKitRangeNotifier;
import com.radiusnetworks.proximity.ProximityKitSyncNotifier;
import com.radiusnetworks.proximity.ProximityKitBeacon;
import com.radiusnetworks.proximity.ProximityKitBeaconRegion;

import java.util.Collection;


public class ProximityKitCordovaApplication extends Application implements ProximityKitRangeNotifier, ProximityKitSyncNotifier, ProximityKitMonitorNotifier {
	
    private static ProximityKitManager pkManager;
    private ProximityKitPlugin pkPlugin = null;
    
    @Override
    public void onCreate()
    {
        super.onCreate();
        Log.d(TAG, "onCreate");
        pkManager = ProximityKitManager.getInstanceForApplication(this);
        pkManager.setProximityKitSyncNotifier(this);
        pkManager.setProximityKitMonitorNotifier(this);
        pkManager.setProximityKitRangeNotifier(this);
    	pkManager.getBeaconManager().setDebug(true);
    	pkManager.start();
    }

    private static final String TAG = "ProximityKitCordovaApplication";
    
    public void setPkPlugin(ProximityKitPlugin plugin) {
    	pkPlugin = plugin;
    }
    
    @Override
    public void didRangeBeaconsInRegion(Collection<ProximityKitBeacon> beacons, ProximityKitBeaconRegion region) {
    	Log.d(TAG, "didRangeBeaconsInRegion");
    	if (pkPlugin != null) {
    		pkPlugin.didRangeBeaconsInRegion(beacons, region);
    	}
    }

    @Override
    public void didEnterRegion(ProximityKitBeaconRegion region) {
    	Log.d(TAG, "didEnterRegion");
    	if (pkPlugin != null) {
    		pkPlugin.didEnterRegion( region);
    	}
    }

    @Override
    public void didExitRegion(ProximityKitBeaconRegion region) {
    	Log.d(TAG, "didExitRegion");
    	if (pkPlugin != null) {
    		pkPlugin.didExitRegion( region);
    	}
    }

    @Override
    public void didDetermineStateForRegion(int state, ProximityKitBeaconRegion region) {
    	Log.d(TAG, "didDetermineStateForRegion");
    	if (pkPlugin != null) {
    		pkPlugin.didDetermineStateForRegion(state, region);
    	}
    }

    @Override
    public void didSync()
    {
    	Log.d(TAG, "didSync");
    	if (pkPlugin != null) {
    		pkPlugin.didSync();
    	}
    }

    @Override
    public void didFailSync(Exception e)
    {
    	Log.d(TAG, "didFailSync");
    	if (pkPlugin != null) {
    		pkPlugin.didFailSync( e);
    	}
    }
    
    public ProximityKitManager getProximityKitManager() {
    
    	return pkManager;
    }

}
