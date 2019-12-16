//
//  AppData.m
//  TGAPP
//
//  Created by Rahul Kalavar on 10/16/14.
//  Copyright (c) 2014 Eeshana. All rights reserved.
//

#import "AppData.h"

@implementation AppData

static AppData *instance = nil;
+ (AppData*)getInstance
{
    //	static AppData *instance = nil;
    if (instance == nil) {
        @synchronized(self) {
            if (instance == nil) {
                instance = [[AppData alloc] init];
                
            }
        }
    }
    return instance;
}

@end
