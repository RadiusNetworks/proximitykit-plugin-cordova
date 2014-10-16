#import <Cordova/CDV.h>
#import <ProximityKit/ProximityKit.h>

@interface RPKCDVPlugin : CDVPlugin<RPKManagerDelegate>

- (void)watchProximity:(CDVInvokedUrlCommand *)command;
- (void)clearWatch:(CDVInvokedUrlCommand *)command;

@end

