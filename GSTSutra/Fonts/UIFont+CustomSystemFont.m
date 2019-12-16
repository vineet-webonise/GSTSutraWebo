//
//  UIFont+CustomSystemFont.m
//  GSTSutra
//
//  Created by niyuj on 1/31/17.
//  Copyright © 2017 niyuj. All rights reserved.
//

#import "UIFont+CustomSystemFont.h"


@implementation UIFont (CustomSystemFont)

+(UIFont *)regularFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:centuryGothicBold size:size];
}

+(UIFont *)boldFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:centuryGothicRegular size:size];
}

@end
