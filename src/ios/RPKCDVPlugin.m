#import "RPKCDVPlugin.h"

NSString * const RRPKCDVEventTypeKey                   = @"eventType";
NSString * const RRPKCDVEventTypeSynced                = @"didSync";
NSString * const RPKCDVEventTypeEnteredRegion         = @"didEnterRegion";
NSString * const RPKCDVEventTypeExitedRegion          = @"didExitRegion";
NSString * const RPKCDVEventTypeDeterminedRegionState = @"didDetermineState";
NSString * const RPKCDVEventTypeRangedBeacon          = @"didRangeBeacon";

NSString * const RPKCDVEventRegionKey                 = @"region";
NSString * const RPKCDVEventRegionNameKey             = @"name";
NSString * const RPKCDVEventRegionIdentifierKey       = @"identifier";
NSString * const RPKCDVEventRegionAttributesKey       = @"attributes";
NSString * const RPKCDVEventRegionStateKey            = @"state";

NSString * const RPKCDVEventBeaconKey                 = @"beacon";

NSString * const RPKCDVEventBeaconUUIDKey             = @"uuid";
NSString * const RPKCDVEventBeaconMajorKey            = @"major";
NSString * const RPKCDVEventBeaconMinorKey            = @"minor";
NSString * const RPKCDVEventBeaconRSSIKey             = @"rssi";
NSString * const RPKCDVEventBeaconProximityKey        = @"proximity";
NSString * const RPKCDVEventBeaconAttributesKey       = @"attributes";

@interface RPKRegion (RPKAdditions)

-(NSDictionary *) toDictionary;

@end

@implementation RPKRegion (RPKAdditions)

-(NSDictionary *) toDictionary
{
  return @{
           RPKCDVEventRegionNameKey: self.name,
           RPKCDVEventRegionIdentifierKey: self.identifier,
           RPKCDVEventRegionAttributesKey: self.attributes,
           };
}

@end

@interface RPKIBeacon (RPKAdditions)

-(NSDictionary *) toDictionary;

@end

@implementation RPKIBeacon (RPKAdditions)

-(NSDictionary *) toDictionary
{
  return @{
           RPKCDVEventBeaconUUIDKey: [self.uuid UUIDString],
           RPKCDVEventBeaconMajorKey: @(self.major),
           RPKCDVEventBeaconMinorKey: @(self.minor),
           RPKCDVEventBeaconRSSIKey: @(self.rssi),
           RPKCDVEventBeaconProximityKey: @(self.proximity),
           RPKCDVEventBeaconAttributesKey: self.attributes
           };
}

@end


@interface RPKCDVPlugin ()

@property (strong, nonatomic) RPKManager *proximityKitManager;
@property (strong, nonatomic) NSMutableSet* watchCallbacks;

@end

@implementation RPKCDVPlugin

-(CDVPlugin *) initWithWebView:(UIWebView *) theWebView
{
  self = [super initWithWebView:(UIWebView *) theWebView];
  if (self) {
    self.proximityKitManager = [RPKManager managerWithDelegate:self];
    [self.proximityKitManager start];
    self.watchCallbacks = [[NSMutableSet alloc] init];
  }
  return self;
}

- (void)dealloc
{
  NSLog(@"Stopping RPKManager");
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

- (void)proximityKitDidSync:(RPKManager *)manager
{
  NSLog(@"didSync");
  [self sendSuccessMessageToAllWatches:[self pluginResultDidSync]];
}

- (void)proximityKit:(RPKManager *)manager didFailWithError:(NSError *)error
{
  NSLog(@"didFailWithError %@", error);
  for (NSString *callbackId in self.watchCallbacks)
  {
  	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
  	[result setKeepCallbackAsBool:YES];
  	[self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }
}

- (void)proximityKit:(RPKManager *)manager didEnter:(RPKRegion *)region {
  NSLog(@"didEnter %@", region);
  [self sendSuccessMessageToAllWatches:[self pluginResultDidEnter:region]];
}

- (void)proximityKit:(RPKManager *)manager didExit:(RPKRegion *)region {
  NSLog(@"didExit %@", region);
  [self sendSuccessMessageToAllWatches:[self pluginResultDidExit:region]];
}

- (void)proximityKit:(RPKManager *)manager didDetermineState:(RPKRegionState)state
           forRegion:(RPKRegion *)region
{
  NSLog(@"didDetermineState %@", region);
  [self sendSuccessMessageToAllWatches:[self pluginResultDidDetermineState:state forRegion:region]];
}

- (void)proximityKit:(RPKManager *)manager didRangeBeacons:(NSArray *)beacons
            inRegion:(RPKRegion *)region
{
  NSLog(@"didRangeBeacons %@", beacons);
  // Callback for each individual beacon, not all at once, because Android receives only one at a time.
  for (RPKIBeacon *beacon in beacons)
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

-(void) sendSuccessMessageToAllWatches:(NSDictionary *) message
{
  for (NSString *callbackId in self.watchCallbacks)
  {
  	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
  	[result setKeepCallbackAsBool:YES];
  	[self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }
}

-(NSDictionary *) pluginResultDidSync
{
  return @{RPKCDVEventTypeKey : RPKCDVEventTypeSynced};
}

-(NSDictionary *) pluginResultDidDetermineState:(RPKRegionState) state forRegion:(RPKRegion *) region
{
  return @{
           RPKCDVEventTypeKey : RPKCDVEventTypeDeterminedRegionState,
           RPKCDVEventRegionStateKey : @(state),
           RPKCDVEventRegionKey : [region toDictionary]
           };
}


-(NSDictionary *) pluginResultDidEnter:(RPKRegion *) region
{
  return @{
           RPKCDVEventTypeKey : RPKCDVEventTypeEnteredRegion,
           RPKCDVEventRegionKey : [region toDictionary]
           };
}

-(NSDictionary *) pluginResultDidExit:(RPKRegion *) region
{
  return @{
           RPKCDVEventTypeKey : RPKCDVEventTypeExitedRegion,
           RPKCDVEventRegionKey : [region toDictionary]
           };
}

-(NSDictionary *) pluginResultDidRangeBeacon:(RPKIBeacon *) beacon
{
  return @{
           RPKCDVEventTypeKey : RPKCDVEventTypeRangedBeacon,
           RPKCDVEventBeaconKey : [beacon toDictionary]
           };
}

@end
