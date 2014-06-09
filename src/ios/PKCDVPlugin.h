#import <Cordova/CDV.h>
#import <ProximityKit/ProximityKit.h>

FOUNDATION_EXPORT NSString * const PKCDVEventTypeKey;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeSynced;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeEnteredRegion;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeExitedRegion;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeDeterminedRegionState;
FOUNDATION_EXPORT NSString * const PKCDVEventTypeRangedBeacons;

FOUNDATION_EXPORT NSString * const PKCDVEventRegionKey;
FOUNDATION_EXPORT NSString * const PKCDVEventRegionName;
FOUNDATION_EXPORT NSString * const PKCDVEventRegionIdentifier;
FOUNDATION_EXPORT NSString * const PKCDVEventRegionAttributes;

FOUNDATION_EXPORT NSString * const PKCDVEventBeaconsKey;

FOUNDATION_EXPORT NSString * const PKCDVEventRegionStateKey;

@interface PKCDVPlugin : CDVPlugin<PKManagerDelegate>

- (void)watchProximity:(CDVInvokedUrlCommand *)command;
- (void)clearWatch:(CDVInvokedUrlCommand *)command;

@end

