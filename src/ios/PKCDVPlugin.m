#import "PKCDVPlugin.h"

NSString * const PKCDVEventTypeKey                   = @"eventType";
NSString * const PKCDVEventTypeSynced                = @"didSync";
NSString * const PKCDVEventTypeEnteredRegion         = @"didEnterRegion";
NSString * const PKCDVEventTypeExitedRegion          = @"didExitRegion";
NSString * const PKCDVEventTypeDeterminedRegionState = @"didDetermineState";
NSString * const PKCDVEventTypeRangedBeacons         = @"didRangeBeacons";
NSString * const PKCDVEventTypeRangedBeacon          = @"didRangeBeacon";

NSString * const PKCDVEventRegionKey                 = @"region";
NSString * const PKCDVEventRegionNameKey             = @"name";
NSString * const PKCDVEventRegionIdentifierKey       = @"identifier";
NSString * const PKCDVEventRegionAttributesKey       = @"attributes";
NSString * const PKCDVEventRegionStateKey            = @"state";

NSString * const PKCDVEventBeaconsKey                = @"beacons";
NSString * const PKCDVEventBeaconKey                 = @"beacon";

NSString * const PKCDVEventBeaconUUIDKey             = @"uuid";
NSString * const PKCDVEventBeaconMajorKey            = @"major";
NSString * const PKCDVEventBeaconMinorKey            = @"minor";
NSString * const PKCDVEventBeaconRSSIKey             = @"rssi";
NSString * const PKCDVEventBeaconProximityKey        = @"proximity";
NSString * const PKCDVEventBeaconAttributesKey       = @"attributes";

@interface PKRegion (PKAdditions)

-(NSDictionary *) toDictionary;

@end

@implementation PKRegion (PKAdditions)

-(NSDictionary *) toDictionary
{
  return @{
           PKCDVEventRegionNameKey: self.name,
           PKCDVEventRegionIdentifierKey: self.identifier,
           PKCDVEventRegionAttributesKey: self.attributes,
           };
}

@end

@interface PKIBeacon (PKAdditions)

-(NSDictionary *) toDictionary;

@end

@implementation PKIBeacon (PKAdditions)

-(NSDictionary *) toDictionary
{
  return @{
           PKCDVEventBeaconUUIDKey: [self.uuid UUIDString],
           PKCDVEventBeaconMajorKey: @(self.major),
           PKCDVEventBeaconMinorKey: @(self.minor),
           PKCDVEventBeaconRSSIKey: @(self.rssi),
           PKCDVEventBeaconProximityKey: @(self.proximity),
           PKCDVEventBeaconAttributesKey: self.attributes
           };
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
  // Callback for each individual beacon, not all at once, because Android receives only one at a time.
  for (PKIBeacon *beacon in beacons)
  {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[self pluginResultDidRangeBeacon:beacon]];
    [result setKeepCallbackAsBool:YES];
    for (NSString *callbackId in self.watchCallbacks)
    {
      [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
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

-(NSDictionary *) pluginResultDidRangeBeacon:(PKIBeacon *) beacon
{
  return @{
           PKCDVEventTypeKey : PKCDVEventTypeRangedBeacon,
           PKCDVEventBeaconKey : [beacon toDictionary]
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
