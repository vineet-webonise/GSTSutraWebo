//
//  Utility.h

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface Utility : NSObject

+ (id)sharedManager;
+(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+(NSString*) md5:(NSString *) input;
+(void)showMessage:(NSString*)message withTitle:(NSString *)title;
+ (BOOL)validateEmailWithString:(NSString*)email;
+(void)SetPanGestureOff;

@end
