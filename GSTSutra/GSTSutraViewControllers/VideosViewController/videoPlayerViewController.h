//
//  videoPlayerViewController.h
//  GSTSutra
//
//  Created by niyuj on 12/26/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "YTPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface videoPlayerViewController : BaseViewController
@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
@property (nonatomic,strong)NSMutableArray *videoPlayerArray;
@property (nonatomic,assign)NSInteger selectedIndex;
@property (nonatomic) BOOL isPresented;
@property (nonatomic,assign) BOOL isFromBookmarks;
@end
