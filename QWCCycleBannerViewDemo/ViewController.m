//
//  ViewController.m
//  QWCCycleBannerViewDemo
//
//  Created by tangqinwei on 15/11/18.
//  Copyright © 2015年 tangqinwei. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "QWCCycleBannerView.h"

@interface ViewController ()<QWCCycleBannerViewDataSource,QWCCycleBannerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    QWCCycleBannerView *cycleBannerView = [[QWCCycleBannerView alloc] initWithFrame:CGRectMake( 10.0f, 20.0f, self.view.frame.size.width - 20.0f, 100.0f )];
    
    [self.view addSubview:cycleBannerView];
    
    cycleBannerView.dataSource       = self;
    cycleBannerView.delegate         = self;
    cycleBannerView.autoPlayInterval = 2.0f;
    cycleBannerView.continuous       = YES;
    
    
   
    
}

#pragma mark - dataSource

-(NSArray *)imageURLStringArray{
    
    NSArray *imagesURLStringArray = @[@"http://www.devqinwei.com/wp-content/uploads/2015/10/cropped-131.jpg",
                                       @"http://www.devqinwei.com/wp-content/uploads/2015/10/cropped-12.jpg",
                                       @"http://www.devqinwei.com/wp-content/uploads/2015/10/cropped-jiuxi09.jpg",
                                    @"http://www.devqinwei.com/wp-content/uploads/2015/10/cropped-topImage07.jpg"];
    
    return imagesURLStringArray;
}

-(UIImage *)cycleBannerPlaceHolderImageWithIndex:(NSInteger)index{
    
    // 这里使用代码创建一个纯色的UIImage
    
    CGSize imageSize = CGSizeMake( self.view.frame.size.width, 100.0f);
    UIColor *fillColor = [UIColor lightGrayColor];
    UIGraphicsBeginImageContextWithOptions( imageSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [fillColor setFill];
    CGContextFillRect( context, CGRectMake( 0.0f, 0.0f, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image; //[UIImage imageNamed:@"placeholder"];
}

-(UIViewContentMode)cycleBannerImageContentMode{
    
    return UIViewContentModeScaleAspectFill;
}

#pragma mark - delegate

-(void)cycleBannerView:(QWCCycleBannerView *)cycleBanerView didSelectImageViewAtIndex:(NSInteger)index{
    
    NSLog(@"点击了第 %ld 页", (long)index); //test
    
}




@end
