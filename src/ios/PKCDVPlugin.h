#import <Cordova/CDV.h>
#import <ProximityKit/ProximityKit.h>

@interface PKCDVPlugin : CDVPlugin<PKManagerDelegate>

- (void)watchProximity:(CDVInvokedUrlCommand *)command;
- (void)clearWatch:(CDVInvokedUrlCommand *)command;

@end

