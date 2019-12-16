//
//  AppData.h
//  TGAPP
//
//  Created by Rahul Kalavar on 10/16/14.
//  Copyright (c) 2014 Eeshana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UserModel.h"
#import "NewsModel.h"



@interface AppData : NSObject

@property(nonatomic, strong)UserModel *currentUser;
@property(nonatomic, strong)NewsModel *newsData;
//@property(nonatomic, strong)pharmaModel *getPharmaData;
//@property(nonatomic, strong)ReOrderModel *reOrder;
@property (nonatomic, strong) NSString *orderID;

+ (AppData *)getInstance;
@end
