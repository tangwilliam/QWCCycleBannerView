//
//  QWCCycleBannerView.h
//  QWCCycleBannerViewDemo
//
//  Created by tangqinwei on 15/11/18.
//  Copyright © 2015年 tangqinwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QWCCycleBannerViewDataSource <NSObject>

@required
-(NSArray *) imageURLStringArray;

@optional
-(UIImage *) cycleBannerPlaceHolderImageWithIndex:(NSInteger) index;
-(UIViewContentMode) cycleBannerImageContentMode;

@end

@interface QWCCycleBannerView : UIView

@property (strong,nonatomic) UIScrollView *scrollView;

@property (strong,nonatomic) UIPageControl *pageControl;

@property (assign,nonatomic) NSTimeInterval autoPlayInterval; /**< 自动播放时间间隔，如果为零或者未设置，则视为不进行自动播放 */

@property (assign,nonatomic, getter=isContinuous) BOOL continuous;

@property (weak,nonatomic) id<QWCCycleBannerViewDataSource> dataSource;


@end

