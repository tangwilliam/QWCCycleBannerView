//
//  QWCCycleBannerView.m
//  QWCCycleBannerViewDemo
//
//  Created by tangqinwei on 15/11/18.
//  Copyright © 2015年 tangqinwei. All rights reserved.
//

#import "QWCCycleBannerView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface QWCCycleBannerView()<UIScrollViewDelegate>

@property (strong,nonatomic) NSArray *imageURLStringArray;

@property (strong,nonatomic) NSMutableArray *imageViewArray; /**< 存放内容的imageView数组，用于内部操作 */
@property (assign,nonatomic) NSInteger currentPage;

@end

@implementation QWCCycleBannerView

#pragma mark - setter and getter

-(NSArray *)imageURLStringArray{
    
    if (!_imageURLStringArray) {
        
        if ( [_dataSource respondsToSelector:@selector(imageURLStringArray)]) {
            
            _imageURLStringArray = [NSArray arrayWithArray:[_dataSource imageURLStringArray]];
        }
    }
    
    return _imageURLStringArray;
}

#pragma mark - 初始化

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    return self;
}

/**
 *  从这个方法中才能开始调用delegate方法
 */
-(void)layoutSubviews{
    
    [self initScrollView];
    
    [self initPageControl];
    
    [self loadData];
}


-(void) initScrollView{
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.frame.size.width , self.frame.size.height ) ];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
}

-(void) initPageControl{
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake( 0.0f , 0.0f, self.frame.size.width, 20.0f)];
    _pageControl.center = CGPointMake( self.frame.size.width / 2, self.frame.size.height - 10 );
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
    
}

-(void) loadData{
    
    // 设置scrollView 内容
    
    if ( self.imageURLStringArray.count ) {
        
        // 如果设置为循环，则需要前后各补充一个元素，用于制造循环视觉效果
        if (self.isContinuous) {
            
            NSMutableArray *tempArray = [self.imageURLStringArray mutableCopy];
            [tempArray insertObject:[self.imageURLStringArray lastObject] atIndex:0];
            [tempArray addObject:[self.imageURLStringArray firstObject]];
            self.imageURLStringArray = [NSMutableArray arrayWithArray:tempArray];
            
        }
        
        __block NSMutableArray *imageViewArray = [NSMutableArray array];
        
        [self.imageURLStringArray enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL * stop) {
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake( idx * self.frame.size.width,
                                                                                   0,
                                                                                   self.frame.size.width,
                                                                                   self.frame.size.height)];
            
            if ( [self.dataSource respondsToSelector:@selector(cycleBannerImageContentMode)]) {
                
                imageView.contentMode = [self.dataSource cycleBannerImageContentMode];
            }else{
                imageView.contentMode = UIViewContentModeScaleAspectFill;
            }
            
            if ([self.dataSource respondsToSelector:@selector(cycleBannerPlaceHolderImageWithIndex:)]) {
                
                UIImage *placeHolder = [self.dataSource cycleBannerPlaceHolderImageWithIndex:idx];
                [imageView setImageWithURL:[NSURL URLWithString:urlString ] placeholderImage:placeHolder];
                
            }else{
                [imageView setImageWithURL:[NSURL URLWithString:urlString ]];
                
            }
            
            [imageViewArray addObject:imageView];
            
        }];
        
        [imageViewArray enumerateObjectsUsingBlock:^(UIImageView  *imageView, NSUInteger idx, BOOL *  stop) {
            
            [_scrollView addSubview:imageView];
            
        }];
        
        [_scrollView setContentSize:CGSizeMake( imageViewArray.count * self.frame.size.width, self.frame.size.height)];
        
        // 保存图片数组，以备后续使用
        _imageViewArray = [[NSMutableArray alloc] initWithArray:imageViewArray];
    }
    
    
    // 设置scrollView滚动初始状态
    
    if(self.isContinuous){
        
        [self moveToOffset:_scrollView.frame.size.width animated:NO];
        
    }
    
    if (_autoPlayInterval) {
        
        [self performSelector:@selector(autoScroll:) withObject:@(_autoPlayInterval) afterDelay:_autoPlayInterval];
    }

    // 设置pageControl 初始状态
    
    if (self.isContinuous) {
        
        _pageControl.numberOfPages = self.imageURLStringArray.count - 2;
    }else{
        
        _pageControl.numberOfPages = self.imageURLStringArray.count;
    }
    _pageControl.currentPage = 0;
}


#pragma mark - 辅助逻辑

-(void) autoScroll:( NSNumber *) interval{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoScroll:) object:nil];
    
    NSTimeInterval timeInterval = [interval doubleValue];
    
    if (timeInterval) {
        
        [self moveToOffset:(_scrollView.contentOffset.x + _scrollView.frame.size.width) animated:YES];
        
        [self performSelector:_cmd withObject:interval afterDelay:timeInterval];
        
    }
    
}

-(void) moveToOffset:(CGFloat) targetOffset animated:(BOOL) animated{
    
    [_scrollView scrollRectToVisible:CGRectMake( targetOffset, 0.0f, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:animated];
}


#pragma mark - scrollView delegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    
    float pageWidth = _scrollView.frame.size.width;
    NSInteger currentPage = (_scrollView.contentOffset.x + pageWidth / 2 ) / pageWidth;  // floor(_scrollView.contentOffset.x / pageWidth);

    if ( self.isContinuous ) {
        
        NSInteger validImageCount = [_imageViewArray count] - 2;
        
        if ( scrollView.contentOffset.x >= ( validImageCount + 1 ) * pageWidth  ) {
            
            [self moveToOffset:pageWidth animated:NO];
        }
        else if( scrollView.contentOffset.x <= 0 ){
            
            [self moveToOffset:( validImageCount * pageWidth) animated:NO];
            
        }
     
        // 设置当移到边界时 pageControl的currentPage

        currentPage--; // 第一页是为了循环而插入的
        
        if( currentPage >= validImageCount ){
            
            currentPage = 0;
            
        }
        else if( currentPage == -1  ){
            
            currentPage = validImageCount - 1;

        }
    }
    
    _pageControl.currentPage = currentPage;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
