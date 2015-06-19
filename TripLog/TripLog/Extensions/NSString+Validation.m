#import "NSString+Validation.h"

@implementation NSString (Validation)

- (BOOL)isEmpty {
    NSCharacterSet *charSet = [NSCharacterSet whitespaceCharacterSet];
    NSString *trimmedString = [self stringByTrimmingCharactersInSet:charSet];
    if ([trimmedString isEqualToString:@""]) {
        return YES;
    }
    return NO;
}
@end
