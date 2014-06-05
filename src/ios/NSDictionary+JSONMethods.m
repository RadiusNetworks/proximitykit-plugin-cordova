#import "NSDictionary+JSONMethods.h"

@implementation NSDictionary (JSONMethods)

-(NSString *) JSONRepresentation
{
	NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString;
    if (jsonData == nil) 
    {
        jsonString = @"{}";
    } 
    else 
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } 
    return jsonString;
}

@end