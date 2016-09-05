
#import <Foundation/Foundation.h>

@interface XPathQuery : NSObject

+(NSArray*)performHTML:(NSData*) document xPathQuery:(NSString*) query;

+(NSArray*)performHTML:(NSData*) document xPathQuery:(NSString*) query encoding:(NSString *)encoding;

+(NSArray*)performXML:(NSData*) document xPathQuery:(NSString*) query;

+(NSArray*)performXML:(NSData*) document xPathQuery:(NSString*) query encoding:(NSString *)encoding;

@end
