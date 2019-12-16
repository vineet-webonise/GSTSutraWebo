//
//  BounceEffectViewController.m
//  GSTSutra
//
//  Created by niyuj on 12/13/16.
//  Copyright © 2016 niyuj. All rights reserved.
//

#import "BounceEffectViewController.h"
#import "ShortNewsViewController.h"
#import "LongNewsViewController.h"
#import "HomeViewController.h"
#import "PLCarouselView.h"

@interface BounceEffectViewController ()<PLCarouselViewDataSource,PLCarouselViewDelegate>

@property (nonatomic,strong) NSArray *colors;

@property (nonatomic,strong) PLCarouselView *carousel;

@end

@implementation BounceEffectViewController

#pragma mark - view life cycle 

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
 
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
        _carousel = [PLCarouselView init];
        [_carousel setFrame:[UIScreen mainScreen].bounds];
        
        _carousel.delegate = self;
        
        _carousel.dataSource = self;
        
        [self.view addSubview:_carousel];
        
        [_carousel reloadData];
    }

#pragma mark - PLCarouselView delegates & datasources
    
    -(UIView *)carouselView:(PLCarouselView *)carouselView viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
    {
        
        if (carouselView == _carousel) {
            
            PLCarouselView *carouselCategory = (PLCarouselView*)view;
            
            
            if (!view) {
                carouselCategory = [PLCarouselView init];
                
                carouselCategory.delegate = self;
                
                carouselCategory.dataSource = self;
                
                [carouselCategory setFrame:[UIScreen mainScreen].bounds];
                
                carouselCategory.vertical = YES;
            }
            //NSLog(@"index Path %d",index);
            
            carouselCategory.tag = index;
            
            [carouselCategory reloadData];
            
            return carouselCategory;
        }
        else {
            
            UIView *viewTemp = view;
            ShortNewsViewController *shortView;
            if(!viewTemp)
            {
                viewTemp = [UIView new];
                shortView = [self.storyboard instantiateViewControllerWithIdentifier:@"ShortNewsViewController"];
            }
            viewTemp.layer.masksToBounds = NO;
            viewTemp.layer.shadowColor = [[UIColor blackColor] CGColor];
            viewTemp.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
            viewTemp.layer.shadowRadius = 3.0f;
            viewTemp.layer.shadowOpacity = 1.0f;
            [viewTemp setFrame:[UIScreen mainScreen].bounds];
            [viewTemp addSubview:shortView.view];
            
            return viewTemp;
        }
    }
    
    -(NSUInteger)numberOfItemsInCarousel:(PLCarouselView *)carouselView
    {
        if (carouselView == _carousel) {
            return self.shortViewNewsArray.count;
        }
        return [self.shortViewNewsArray count];
    }
    
    -(void)carouselView:(PLCarouselView *)carouselView didMoveToView:(UIView *)view
    {
        //NSLog(@"Did Move To view Call");
        
    }
    
    -(void)carouselCurrentItemIndexDidChange:(PLCarouselView *)carouselView currentIndex:(NSUInteger)currentIndex previousIndex:(NSUInteger)previousIndex
    {
        //NSLog(@"CurrentItemIndexDidChange called ");
        //NSLog(@"CurrentItemIndex %lu",(unsigned long)currentIndex);
        //NSLog(@"PreviousItemIndex %lu",(unsigned long)previousIndex);
    }
    
    -(void)carouselView:(PLCarouselView *)carouselView didSelectItemAtIndex:(NSUInteger)index
    {
        //NSLog(@"didSelectItemAtIndex called %lu",(unsigned long)index);
    }
    
    -(void)carouselView:(PLCarouselView *)carouselView changedScrollDirection:(PLCarouselViewDirection)direction
    {
        
        switch (direction) {
            case PLCarouselViewDirectionDown:
            {
                //NSLog(@"ViewDirectionDown");
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
                break;
            case PLCarouselViewDirectionUp:
            {
                //NSLog(@"ViewDirectionUp");
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
                break;
            case PLCarouselViewDirectionLeft:
            {
                //NSLog(@"ViewDirectionleft");
                //[self.navigationController popViewControllerAnimated:YES];
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                
                
            }
                break;
            case PLCarouselViewDirectionRight:
            {
                //NSLog(@"ViewDirectionRight");
                LongNewsViewController *Longview = [self.storyboard instantiateViewControllerWithIdentifier:@"LongNewsViewController"];
                Longview.selectedIndex = self.selectedIndex;
                Longview.longViewNewsArray = self.shortViewNewsArray;
                [self.navigationController pushViewController:Longview animated:YES];
                [self.navigationController setNavigationBarHidden:NO animated:YES];
            }
                break;
            case PLCarouselViewDirectionStatic:
            {
                 //NSLog(@"ViewDirectionStatic");
                
            }
                break;
            default:
                break;
        }
    }
    
    -(void)carouselView:(PLCarouselView *)carouselView didScrollDiffrenceRate:(CGFloat)diffRate
    {
        //NSLog(@"didScrollDiffrenceRate called ");
    }

@end
