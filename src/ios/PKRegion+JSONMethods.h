#import <ProximityKit/ProximityKit.h>

FOUNDATION_EXPORT NSString * const PKRegionNameKey;
FOUNDATION_EXPORT NSString * const PKRegionIdentifierKey;
FOUNDATION_EXPORT NSString * const PKRegionAttributesKey;

@interface PKRegion (JSONMethods)

-(NSString *) JSONRepresentation;

@end
