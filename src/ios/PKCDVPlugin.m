#import "PKCDVPlugin.h"

NSString * const PKCDVEventTypeKey                   = @"eventType";
NSString * const PKCDVEventTypeSynced                = @"didSync";
NSString * const PKCDVEventTypeEnteredRegion         = @"didEnterRegion";
NSString * const PKCDVEventTypeExitedRegion          = @"didExitRegion";
NSString * const PKCDVEventTypeDeterminedRegionState = @"didDetermineState";
NSString * const PKCDVEventTypeRangedBeacons         = @"didRangeBeacons";

NSString * const PKCDVEventRegionKey                 = @"region";
NSString * const PKCDVEventRegionName                = @"name";
NSString * const PKCDVEventRegionIdentifier          = @"identifier";
NSString * const PKCDVEventRegionAttributes          = @"attributes";

NSString * const PKCDVEventBeaconsKey                = @"beacons";

NSString * const PKCDVEventRegionStateKey            = @"state";

NSString * const PKCDVEventBeaconUUIDKey             = @"uuid";
NSString * const PKCDVEventBeaconMajorKey            = @"major";
NSString * const PKCDVEventBeaconMinorKey            = @"minor";
NSString * const PKCDVEventBeaconRSSIKey             = @"rssi";
NSString * const PKCDVEventBeaconProximityKey        = @"proximity";

@interface PKRegion (PKAdditions)

-(NSDictionary *) toDictionary;

@end

@implementation PKRegion (PKAdditions)

-(NSDictionary *) toDictionary
{
  return @{
           PKCDVEventRegionName: self.name,
           PKCDVEventRegionIdentifier: self.identifier,
           PKCDVEventRegionAttributes: self.attributes,
           };
}

@end

@interface PKIBeacon (PKAdditions)

-(NSDictionary *) toDictionary;

@end

@implementation PKIBeacon (PKAdditions)

-(NSDictionary *) toDictionary
{
  NSMutableDictionary *combinedDictionary = [[NSMutableDictionary alloc] initWithDictionary:[super toDictionary]];
  [combinedDictionary addEntriesFromDictionary:
   @{
     PKCDVEventBeaconUUIDKey: [self.uuid UUIDString],
     PKCDVEventBeaconMajorKey: @(self.major),
     PKCDVEventBeaconMinorKey: @(self.minor),
     PKCDVEventBeaconRSSIKey: @(self.rssi),
     PKCDVEventBeaconProximityKey: @(self.proximity)
     }];
  return combinedDictionary;
}

@end


@interface PKCDVPlugin ()

@property (strong, nonatomic) PKManager *proximityKitManager;
@property (strong, nonatomic) NSMutableSet* watchCallbacks;

@end

@implementation PKCDVPlugin

-(CDVPlugin *) initWithWebView:(UIWebView *) theWebView
{
    self = [super initWithWebView:(UIWebView *) theWebView];
    if (self) {
   		self.proximityKitManager = [PKManager managerWithDelegate:self];
    	[self.proximityKitManager start];
    	self.watchCallbacks = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
	NSLog(@"Stopping PKManager");
    self.proximityKitManager.delegate = nil;
    [self.proximityKitManager stop];
    self.proximityKitManager = nil;
}

- (void)watchProximity:(CDVInvokedUrlCommand*)command
{
    [self.watchCallbacks addObject:command.callbackId];
}

- (void)clearWatch:(CDVInvokedUrlCommand*)command;
{
    [self.watchCallbacks removeObject:command.callbackId];
}

- (void)onReset
{
}

#pragma mark -
#pragma mark ProximityKit delegate methods

- (void)proximityKitDidSync:(PKManager *)manager
{
  for (NSString *callbackId in self.watchCallbacks)
  {
  	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self pluginResultDidSync]];
  	[result setKeepCallbackAsBool:YES];
  	[self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }
}

- (void)proximityKit:(PKManager *)manager didFailWithError:(NSError *)error
{
  NSLog(@"didFailWithError %@", error);
  for (NSString *callbackId in self.watchCallbacks)
  {
  	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
  	[result setKeepCallbackAsBool:YES];
  	[self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }
}

- (void)proximityKit:(PKManager *)manager didEnter:(PKRegion *)region {
  NSLog(@"didEnter %@", region);
  for (NSString *callbackId in self.watchCallbacks)
  {
  	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self pluginResultDidEnter:region]];
  	[result setKeepCallbackAsBool:YES];
  	[self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }
}

- (void)proximityKit:(PKManager *)manager didExit:(PKRegion *)region {
  NSLog(@"didExit %@", region);
  for (NSString *callbackId in self.watchCallbacks)
  {
  	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self pluginResultDidExit:region]];
  	[result setKeepCallbackAsBool:YES];
  	[self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }
}

- (void)proximityKit:(PKManager *)manager didDetermineState:(PKRegionState)state
            forRegion:(PKRegion *)region
{
  NSLog(@"didDetermineState %@", region);
  for (NSString *callbackId in self.watchCallbacks)
  {
  	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self pluginResultDidDetermineState:state forRegion:region]];
  	[result setKeepCallbackAsBool:YES];
  	[self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }
}

- (void)proximityKit:(PKManager *)manager didRangeBeacons:(NSArray *)beacons
            inRegion:(PKRegion *)region
{
  NSLog(@"didRangeBeacons %@", beacons);
  for (NSString *callbackId in self.watchCallbacks)
  {
  	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self pluginResultDidRangeBeacons:beacons inRegion:region]];
  	[result setKeepCallbackAsBool:YES];
  	[self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }
}

#pragma mark - Plugin Results

-(NSDictionary *) pluginResultDidSync
{
  return @{PKCDVEventTypeKey : PKCDVEventTypeSynced};
}

-(NSDictionary *) pluginResultDidDetermineState:(PKRegionState) state forRegion:(PKRegion *) region
{
  return @{
           PKCDVEventTypeKey : PKCDVEventTypeDeterminedRegionState,
           PKCDVEventRegionStateKey : @(state),
           PKCDVEventRegionKey : [region toDictionary]
           };
}


-(NSDictionary *) pluginResultDidEnter:(PKRegion *) region
{
  return @{
           PKCDVEventTypeKey : PKCDVEventTypeEnteredRegion,
           PKCDVEventRegionKey : [region toDictionary]
           };
}

-(NSDictionary *) pluginResultDidExit:(PKRegion *) region
{
  return @{
           PKCDVEventTypeKey : PKCDVEventTypeExitedRegion,
           PKCDVEventRegionKey : [region toDictionary]
           };
}

-(NSDictionary *) pluginResultDidRangeBeacons:(NSArray *) beacons inRegion:(PKRegion *) region
{
  return @{
           PKCDVEventTypeKey : PKCDVEventTypeRangedBeacons,
           PKCDVEventRegionKey : [region toDictionary],
           PKCDVEventBeaconsKey : [self JSONSafeBeaconArray:beacons]
           };
}

-(NSArray *) JSONSafeBeaconArray:(NSArray *) beacons
{
  NSMutableArray *safeBeaconArray = [NSMutableArray arrayWithCapacity:beacons.count];
  for (PKIBeacon *beacon in beacons)
  {
    [safeBeaconArray addObject:[((PKIBeacon *) beacon) toDictionary]];
  }
  return safeBeaconArray;
}

@end
