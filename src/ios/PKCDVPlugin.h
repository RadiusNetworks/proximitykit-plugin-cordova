#import <Cordova/CDV.h>
#import <ProximityKit/ProximityKit.h>

FOUNDATION_EXPORT NSString * const PKCDVEventTypeKey;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeSynced;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeEnteredRegion;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeExitedRegion;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeDeterminedRegionState;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeRangedBeacons;

@interface PKCDVPlugin : CDVPlugin<PKManagerDelegate>

- (void)watchProximity:(CDVInvokedUrlCommand *)command;
- (void)clearWatch:(CDVInvokedUrlCommand *)command;

@end

