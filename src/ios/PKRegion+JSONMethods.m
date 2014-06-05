#import "PKRegion+JSONMethods.h"

NSString * const PKRegionNameKey       = @"name";
NSString * const PKRegionIdentifierKey = @"identifier";
NSString * const PKRegionAttributesKey = @"attributes";

@implementation PKRegion (JSONMethods)

-(NSString *) JSONRepresentation
{
	return @{PKRegionNameKey : self.name};
}

@end
