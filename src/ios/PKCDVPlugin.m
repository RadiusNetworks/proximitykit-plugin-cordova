#import "PKCDVPlugin.h"

NSString * const PKCDVEventTypeKey                   = @"eventType";
NSString * const PKCDVEventTypeSynced                = @"didSync";
NSString * const PKCDVEventTypeEnteredRegion         = @"didEnterRegion";
NSString * const PKCDVEventTypeExitedRegion          = @"didExitRegion";
NSString * const PKCDVEventTypeDeterminedRegionState = @"didDetermineState";
NSString * const PKCDVEventTypeRangedBeacons         = @"didRangeBeacons";

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
  NSLog(@"didSync");
  for (NSString *callbackId in self.watchCallbacks)
  {
  	CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"didSync"];
  	[result setKeepCallbackAsBool:YES];
  	[self.commandDelegate sendPluginResult:result callbackId:callbackId];
  }
}

- (void)proximityKit:(PKManager *)manager didFailWithError:(NSError *)error
{
  NSLog(@"didFailWithError %@", error);
}

- (void)proximityKit:(PKManager *)manager didEnter:(PKRegion *)region {
	  NSLog(@"didEnter %@", region);
}

- (void)proximityKit:(PKManager *)manager didExit:(PKRegion *)region {
	  NSLog(@"didExit %@", region);
}

- (void)proximityKit:(PKManager *)manager didDetermineState:(PKRegionState)state
            forRegion:(PKRegion *)region
{
  NSLog(@"didDetermineState %@", region);
}

- (void)proximityKit:(PKManager *)manager didRangeBeacons:(NSArray *)beacons
            inRegion:(PKRegion *)region
{
  NSLog(@"didRangeBeacons %@", beacons);
}

@end
